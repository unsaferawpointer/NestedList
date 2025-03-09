//
//  UnitPresenter.swift
//  macOS
//
//  Created by Anton Cherkasov on 16.11.2024.
//

import Foundation
import CoreModule
import DesignSystem
import Hierarchy

import AppKit

protocol UnitPresenterProtocol: AnyObject {
	func present(_ content: Content)
}

final class UnitPresenter {

	// MARK: - DI

	var interactor: UnitInteractorProtocol?

	weak var view: UnitView?

	private(set) var factory: ItemsFactoryProtocol = ItemsFactory()

	// MARK: - Constants

	private let stringType = NSPasteboard.PasteboardType.string.rawValue

	// MARK: - Cache

	var cache = Cache<Property, Item>()
}

// MARK: - UnitPresenterProtocol
extension UnitPresenter: UnitPresenterProtocol {

	func present(_ content: Content) {

		var snapshot = Snapshot(content.root.nodes)
		snapshot.validate(keyPath: \.isDone)
		snapshot.validate(keyPath: \.isMarked)

		cache.store(.isDone, keyPath: \.isDone, equalsTo: true, from: snapshot)
		cache.store(.isMarked, keyPath: \.isMarked, equalsTo: true, from: snapshot)
		cache.store(.isItem, keyPath: \.style, equalsTo: .item, from: snapshot)
		cache.store(.isSection, keyPath: \.style, equalsTo: .section, from: snapshot)

		let converted = snapshot.map { info in
			factory.makeItem(
				item: info.model,
				level: info.level
			)
		}

		view?.display(converted)
	}
}

// MARK: - ListDelegate
extension UnitPresenter: ListDelegate {

	func handleDoubleClick(on item: UUID) {
		interactor?.toggleStatus(for: item, moveToEnd: false)
	}
}

// MARK: - ViewDelegate
extension UnitPresenter: ViewDelegate {

	func viewDidChange(state: ViewState) {
		guard case .didLoad = state else {
			return
		}
		interactor?.fetchData()
		view?.expand(nil)
	}
}

// MARK: - UnitViewOutput
extension UnitPresenter: UnitViewOutput {

	func userCreateNewItem() {
		guard let interactor else {
			return
		}

		let first = view?.selection.first
		let id = interactor.newItem("New...", target: first)

		view?.scroll(to: id)
		if let first {
			view?.expand([first])
		}
		view?.focus(on: id, key: "title")
	}

	func userDeleteItem() {
		guard let selection = view?.selection else {
			return
		}
		interactor?.deleteItems(selection)
	}

	func userChangedStatus(_ status: Bool) {
		guard let selection = view?.selection else {
			return
		}
		interactor?.setStatus(status, for: selection, moveToEnd: false)
	}

	func userChangedMark(_ mark: Bool) {
		guard let selection = view?.selection else {
			return
		}
		interactor?.setMark(mark, for: selection)
	}

	func userChangedStyle(_ style: Item.Style) {
		guard let selection = view?.selection else {
			return
		}
		interactor?.setStyle(style, for: selection)
	}

	func pasteIsAvailable() -> Bool {
		let types = Set([stringType])
		let pasteboard = Pasteboard(pasteboard: NSPasteboard.general)
		return pasteboard.contains(types)
	}

	func userCopyItems() {
		guard
			let selection = view?.selection, !selection.isEmpty,
			let strings = interactor?.strings(for: selection)
		else {
			return
		}

		let items = strings.map { string in
			PasteboardInfo.Item(string: string)
		}

		let info = PasteboardInfo(items: items)

		let pasteboard = Pasteboard(pasteboard: NSPasteboard.general)
		pasteboard.setInfo(info, clearContents: true)
	}

	func userPaste() {

		let pasteboard = Pasteboard(pasteboard: NSPasteboard.general)

		guard
			let info = pasteboard.getInfo()
		else {
			return
		}

		let destination: Destination<UUID> = if let first = view?.selection.first {
			.onItem(with: first)
		} else {
			.toRoot
		}

		let strings = info.items.compactMap { item in
			item.data[stringType]
		}.compactMap { data in
			String(data: data, encoding: .utf8)
		}

		interactor?.insertStrings(strings, to: destination)
	}

	func userCut() {
		guard
			let selection = view?.selection, !selection.isEmpty,
			let strings = interactor?.strings(for: selection)
		else {
			return
		}

		let items = strings.map { string in
			PasteboardInfo.Item(string: string)
		}

		let info = PasteboardInfo(items: items)

		let pasteboard = Pasteboard(pasteboard: NSPasteboard.general)
		pasteboard.setInfo(info, clearContents: true)
		interactor?.deleteItems(selection)
	}

	func userAddNote() {
		guard
			let selection = view?.selection, let first = selection.first
		else {
			return
		}
		interactor?.addNote(for: [first])
		view?.focus(on: first, key: "subtitle")
	}

	func userDeleteNote() {
		guard
			let selection = view?.selection, !selection.isEmpty
		else {
			return
		}
		interactor?.deleteNote(for: selection)
	}
}

// MARK: - DropDelelgate
extension UnitPresenter: DropDelegate {

	typealias ID = UUID

	func move(_ ids: [UUID], to destination: Destination<UUID>) {
		interactor?.move(ids, to: destination)
	}

	func copy(_ ids: [UUID], to destination: Destination<UUID>) {
		interactor?.copy(ids, to: destination)
	}

	func validateMovement(_ ids: [UUID], to destination: Destination<UUID>) -> Bool {
		interactor?.validateMovement(ids, to: destination) ?? false
	}

	func validateDrop(_ info: PasteboardInfo, to destination: Destination<UUID>) -> Bool {
		info.containsInfo(of: stringType)
	}

	func drop(_ info: PasteboardInfo, to destination: Destination<UUID>) {

		let strings = info.items.compactMap { item in
			item.data[stringType]
		}.compactMap { data in
			String(data: data, encoding: .utf8)
		}

		interactor?.insertStrings(strings, to: destination)
	}
}

// MARK: - DragDelegate
extension UnitPresenter: DragDelegate {

	func write(ids: [UUID], to pasteboard: any PasteboardProtocol) {
		guard let strings = interactor?.strings(for: ids) else {
			return
		}

		let items = strings.map { string in
			PasteboardInfo.Item(string: string)
		}

		let info = PasteboardInfo(items: items)
		pasteboard.setInfo(info, clearContents: false)
	}

}

// MARK: - CellDelegate
extension UnitPresenter: CellDelegate {

	typealias Model = ItemModel

	func cellDidChange(newValue: ItemModel.Value, id: UUID) {
		guard !newValue.title.isEmpty else {
			interactor?.deleteItems([id])
			return
		}
		let note: String? = if let subtitle = newValue.subtitle {
			subtitle.isEmpty ? nil : subtitle
		} else {
			nil
		}
		interactor?.set(text: newValue.title, note: note, for: id)
	}
}
extension UnitPresenter {

	func validateStatus() -> Bool? {
		guard let selection = view?.selection, !selection.isEmpty else {
			return false
		}
		return cache.validate(.isDone, other: selection)
	}

	func validateMark() -> Bool? {
		guard let selection = view?.selection, !selection.isEmpty else {
			return false
		}
		return cache.validate(.isMarked, other: selection)
	}

	func validateStyle(_ style: Item.Style) -> Bool? {
		guard let selection = view?.selection, !selection.isEmpty else {
			return false
		}
		switch style {
		case .item:
			return cache.validate(.isItem, other: selection)
		case .section:
			return cache.validate(.isSection, other: selection)
		}
	}
}

final class Cache<Property: Hashable, Model: Identifiable> {

	private var storage: [Property: Set<Model.ID>] = [:]

	func store<T: Equatable>(_ property: Property, keyPath: KeyPath<Model, T>, equalsTo value: T, from snapshot: Snapshot<Model>) {
		storage[property] = snapshot.satisfy { model in
			model[keyPath: keyPath] == value
		}
	}

	func validate(_ property: Property, other: [Model.ID]) -> Bool? {
		guard let stored = storage[property] else {
			return nil
		}
		return validate(in: stored, with: other)
	}
}

// MARK: - Helpers
private extension Cache {

	func validate(in cache: Set<Model.ID>, with other: [Model.ID]) -> Bool? {
		let count = Set(other).intersection(cache).count
		switch count {
		case 0:
			return false
		case other.count:
			return true
		default:
			return nil
		}
	}
}

enum Property: Hashable {
	case isDone
	case isMarked
	case isItem
	case isSection
}

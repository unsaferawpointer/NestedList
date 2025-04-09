//
//  ContentPresenter.swift
//  macOS
//
//  Created by Anton Cherkasov on 16.11.2024.
//

import Foundation

import CoreModule
import DesignSystem
import Hierarchy
import CoreSettings

import AppKit

protocol ContentPresenterProtocol: AnyObject {
	func present(_ content: Content)
}

final class ContentPresenter {

	// MARK: - DI

	var interactor: ContentInteractorProtocol?

	weak var view: UnitView?

	private(set) var factory: ItemsFactoryProtocol = ItemsFactory()

	// MARK: - Constants

	private let stringType = NSPasteboard.PasteboardType.string.rawValue

	var settingsProvider: any StateProviderProtocol<Settings>

	// MARK: - Cache

	var cache = Cache<Property, Item>()

	init(settingsProvider: any StateProviderProtocol<Settings> = SettingsProvider.shared) {
		self.settingsProvider = settingsProvider

		settingsProvider.addObservation(for: self) { [weak self] _, settings in
			self?.interactor?.fetchData()
		}
	}
}

// MARK: - ContentPresenterProtocol
extension ContentPresenter: ContentPresenterProtocol {

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
				level: info.level,
				sectionStyle: settingsProvider.state.sectionStyle
			)
		}

		view?.display(converted)
	}
}

// MARK: - ListDelegate
extension ContentPresenter: ListDelegate {

	func handleDoubleClick(on item: UUID) {
		let completionBehaviour = settingsProvider.state.completionBehaviour
		let moveToEnd = completionBehaviour == .moveToEnd
		interactor?.toggleStatus(for: item, moveToEnd: moveToEnd)
	}
}

// MARK: - ViewDelegate
extension ContentPresenter: ViewDelegate {

	func viewDidChange(state: ViewState) {
		guard case .didLoad = state else {
			return
		}
		interactor?.fetchData()
		view?.expand(nil)
	}
}

// MARK: - UnitViewOutput
extension ContentPresenter: UnitViewOutput {

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
		let completionBehaviour = settingsProvider.state.completionBehaviour
		let moveToEnd = completionBehaviour == .moveToEnd
		interactor?.setStatus(status, for: selection, moveToEnd: moveToEnd)
	}

	func userChangedMark(_ mark: Bool) {
		guard let selection = view?.selection else {
			return
		}
		let markingBehaviour = settingsProvider.state.markingBehaviour
		let moveToTop = markingBehaviour == .moveToTop
		interactor?.setMark(mark, for: selection, moveToTop: moveToTop)
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
extension ContentPresenter: DropDelegate {

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
extension ContentPresenter: DragDelegate {

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
extension ContentPresenter: CellDelegate {

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
extension ContentPresenter {

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

enum Property: Hashable {
	case isDone
	case isMarked
	case isItem
	case isSection
}

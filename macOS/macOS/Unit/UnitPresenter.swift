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

	var interactor: UnitInteractorProtocol?

	weak var view: UnitView?

	// MARK: - Constants

	private let stringType = NSPasteboard.PasteboardType.string.rawValue

	// MARK: - Cache

	private(set) var cache: [UUID: Bool] = [:]
}

// MARK: - UnitPresenterProtocol
extension UnitPresenter: UnitPresenterProtocol {

	func present(_ content: Content) {

		let snapshot = Snapshot(content.root.nodes, keyPath: \.isDone)
		self.cache = snapshot.cache



		let converted = snapshot
			.map { item, isDone, level in

				let style: ItemModel.Style = switch item.style {
				case .item:
					.point(.tertiaryLabelColor)
				case .section:
					.section
				}

				return ItemModel(
					id: item.id,
					value: .init(text: item.text),
					configuration: .init(
						textColor: isDone ? .secondaryLabelColor : .labelColor,
						strikethrough: isDone,
						style: style
					),
					isGroup: level == 0 && style == .section
				)
			}
		view?.display(converted)
	}
}

// MARK: - UnitViewOutput
extension UnitPresenter: UnitViewOutput {

	func viewDidLoad() {
		interactor?.fetchData()
		view?.expand(nil)
	}

	func userCreateNewItem() {
		guard let interactor else {
			return
		}

		let first = view?.selection.first
		let id = interactor.newItem("New Item", target: first)

		view?.scroll(to: id)
		if let first {
			view?.expand([first])
		}
		view?.focus(on: id)
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
		guard !newValue.text.isEmpty else {
			interactor?.deleteItems([id])
			return
		}
		interactor?.setText(newValue.text, for: id)
	}
}
extension UnitPresenter {

	func validateStatus() -> Bool? {
		guard let selection = view?.selection, !selection.isEmpty else {
			return false
		}
		let allDone = selection.compactMap {
			cache[$0]
		}.allSatisfy { $0 }

		let allUndone = selection.compactMap {
			cache[$0]
		}.allSatisfy { !$0 }

		switch (allDone, allUndone) {
		case (false, false):
			return nil
		case (true, false):
			return true
		case (false, true):
			return false
		default:
			fatalError()
		}
	}
}

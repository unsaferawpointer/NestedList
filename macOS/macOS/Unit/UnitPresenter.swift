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

protocol UnitPresenterProtocol: AnyObject {
	func present(_ content: Content)
}

final class UnitPresenter {

	var interactor: UnitInteractorProtocol?

	weak var view: UnitView?

	// MARK: - Cache

	private(set) var cache: [UUID: Bool] = [:]
}

// MARK: - UnitPresenterProtocol
extension UnitPresenter: UnitPresenterProtocol {

	func present(_ content: Content) {

		let snapshot = Snapshot(content.root.nodes, keyPath: \.isDone)
		self.cache = snapshot.cache

		let converted = snapshot
			.map { item, isDone in
				ItemModel(
					id: item.id,
					value: .init(text: item.text),
					configuration: .init(
						textColor: isDone ? .secondaryLabelColor : .labelColor,
						strikethrough: isDone,
						prefixColor: .tertiaryLabelColor
					)
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
}

// MARK: - DropDelelgate
extension UnitPresenter: DropDelegate {

	typealias ID = UUID

	func move(_ ids: [UUID], to destination: Destination<UUID>) {
		interactor?.move(ids, to: destination)
	}

	func copy(_ ids: [UUID], to destination: Hierarchy.Destination<UUID>) {
		interactor?.copy(ids, to: destination)
	}

	func validateMovement(_ ids: [UUID], to destination: Destination<UUID>) -> Bool {
		interactor?.validateMovement(ids, to: destination) ?? false
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

		print("items = \(items)")

		let info = PasteboardInfo(items: items)
		pasteboard.setInfo(info, clearContents: false)
	}

}

// MARK: - CellDelegate
extension UnitPresenter: CellDelegate {

	typealias Model = ItemModel

	func cellDidChange(newValue: ItemModel.Value, id: UUID) {
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

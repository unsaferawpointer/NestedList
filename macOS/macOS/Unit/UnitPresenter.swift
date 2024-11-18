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
}

// MARK: - UnitPresenterProtocol
extension UnitPresenter: UnitPresenterProtocol {

	func present(_ content: Content) {
		let snapshot = Snapshot(content.root.nodes)
			.map { item in
				ItemModel(
					id: item.id,
					value: .init(text: item.text),
					configuration: .init(
						textColor: item.isDone ? .secondaryLabelColor : .labelColor,
						strikethrough: item.isDone
					)
				)
			}
		view?.display(snapshot)
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
}

// MARK: - DropDelelgate
extension UnitPresenter: DropDelegate {

	typealias ID = UUID

	func move(_ ids: [UUID], to destination: Destination<UUID>) {
		interactor?.move(ids, to: destination)
	}

	func validateMovement(_ ids: [UUID], to destination: Destination<UUID>) -> Bool {
		interactor?.validateMovement(ids, to: destination) ?? false
	}
}

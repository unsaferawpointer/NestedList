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
					value: .init(
						isOn: item.isDone,
						text: item.text
					),
					configuration: .init(textColor: .labelColor)
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

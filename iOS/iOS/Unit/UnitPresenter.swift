//
//  UnitPresenter.swift
//  iOS
//
//  Created by Anton Cherkasov on 22.11.2024.
//

import Foundation
import Hierarchy
import CoreModule

protocol UnitPresenterProtocol: AnyObject {
	func present(_ content: Content)
}

final class UnitPresenter {

	var interactor: UnitInteractorProtocol?

	var view: UnitView?
}

// MARK: - UnitPresenterProtocol
extension UnitPresenter: UnitPresenterProtocol {

	func present(_ content: Content) {
		let snapshot = Snapshot(content.root.nodes, keyPath: \.isDone)
			.map { model, isDone in
				ItemModel(
					uuid: model.id,
					title: model.text,
					isDone: isDone
				)
			}
		view?.display(snapshot)
	}
}

extension UnitPresenter: UnitViewDelegate {

	func createNew(target: UUID?) {
		interactor?.newItem("New Item", target: target)
	}

	func updateView() {
		interactor?.fetchData()
	}
}

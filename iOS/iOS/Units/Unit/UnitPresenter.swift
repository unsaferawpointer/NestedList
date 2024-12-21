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
			.map { model, isDone, level in
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

	func userTappedCreateButton() {
		let item = ItemModel(uuid: .init(), title: "", isDone: false)
		view?.showDetails(with: item) { [weak self] saved, success in
			self?.interactor?.newItem(saved.title, target: nil)
			self?.view?.hideDetails()
		}
	}
	
	func userTappedEditButton(id: UUID) {
		fatalError()
	}
	
	func userTappedDeleteButton(ids: [UUID]) {
		interactor?.deleteItems(ids)
	}
	
	func userTappedAddButton(target: UUID) {
		let item = ItemModel(uuid: .init(), title: "", isDone: false)
		view?.showDetails(with: item) { [weak self] saved, success in
			self?.view?.hideDetails()
			self?.interactor?.newItem(saved.title, target: target)
			self?.view?.expand(target)
		}
	}

	func userSetStatus(isDone: Bool, id: UUID) {
		interactor?.setStatus(isDone, for: id)
	}

	func updateView() {
		interactor?.fetchData()
	}
}

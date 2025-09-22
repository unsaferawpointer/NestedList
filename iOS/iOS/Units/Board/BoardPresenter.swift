//
//  BoardPresenter.swift
//  iOS
//
//  Created by Anton Cherkasov on 22.09.2025.
//

import Foundation

import DesignSystem

protocol BoardPresenterProtocol: AnyObject {
	func present(columns: [UUID])
}

final class BoardPresenter {

	// MARK: - DI by Property

	weak var view: BoardView?

	var interactor: BoardInteractorProtocol?
}

// MARK: - BoardPresenterProtocol
extension BoardPresenter: BoardPresenterProtocol {

	func present(columns: [UUID]) {
		view?.display(columns: columns)
	}
}

// MARK: - ViewDelegate
extension BoardPresenter: ViewDelegate {

	func viewDidChange(state: ViewState) {
		guard case .didLoad = state else {
			return
		}
		interactor?.fetchData()
	}
}

// MARK: - BoardViewDelegate
extension BoardPresenter: BoardViewDelegate { }

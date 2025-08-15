//
//  ColumnsPresenter.swift
//  Nested List
//
//  Created by Anton Cherkasov on 14.08.2025.
//

import Hierarchy
import CoreModule
import DesignSystem

protocol ColumnsPresenterProtocol: AnyObject {
	func present(_ nodes: [Node<Item>])
}

final class ColumnsPresenter {

	// MARK: - DI

	var interactor: ColumnsInteractorProtocol?

	weak var view: ColumnsUnitView?
}

// MARK: - ColumnsViewOutput
extension ColumnsPresenter: ColumnsViewOutput {

	func viewDidChange(state: ViewState) {
		guard state == .didLoad else {
			return
		}
		interactor?.fetchData()
	}
}

// MARK: - ColumnsPresenterProtocol
extension ColumnsPresenter: ColumnsPresenterProtocol {

	func present(_ nodes: [Node<Item>]) {
		let columns = nodes.map(\.id)
		view?.display(columns)
	}
}

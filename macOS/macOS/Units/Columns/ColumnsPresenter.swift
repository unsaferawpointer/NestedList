//
//  ColumnsPresenter.swift
//  Nested List
//
//  Created by Anton Cherkasov on 14.08.2025.
//

import DesignSystem

protocol ColumnsPresenterProtocol: AnyObject { }

final class ColumnsPresenter {

	// MARK: - DI

	var interactor: ColumnsInteractorProtocol?

	weak var view: ColumnsUnitView?
}

// MARK: - ColumnsViewOutput
extension ColumnsPresenter: ColumnsViewOutput {

	func viewDidChange(state: ViewState) {
		fatalError()
	}
}

// MARK: - ColumnsPresenterProtocol
extension ColumnsPresenter: ColumnsPresenterProtocol { }

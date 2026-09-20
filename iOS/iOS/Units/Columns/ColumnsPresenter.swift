//
//  ColumnsPresenter.swift
//  iOS
//

import Foundation
import DesignSystem

@MainActor
protocol ColumnsPresenterProtocol: AnyObject {
	func present(_ columns: [UUID])
}

@MainActor
protocol ColumnsViewOutput: ViewDelegate { }

@MainActor
final class ColumnsPresenter {

	weak var view: (any ColumnsView)?

	var interactor: (any ColumnsInteractorProtocol)?
}

// MARK: - ViewDelegate
extension ColumnsPresenter: ViewDelegate {

	func viewDidChange(state: ViewState) {
		guard state == .didLoad else {
			return
		}
		interactor?.fetchData()
	}
}

// MARK: - ColumnsPresenterProtocol
extension ColumnsPresenter: ColumnsPresenterProtocol {

	func present(_ columns: [UUID]) {
		view?.display(columns)
	}
}

// MARK: - ColumnsViewOutput
extension ColumnsPresenter: ColumnsViewOutput { }

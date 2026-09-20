//
//  ColumnPresenter.swift
//  iOS
//

import DesignSystem
import Foundation

@MainActor
protocol ColumnPresenterProtocol: AnyObject {
	func present()
}

@MainActor
protocol ColumnViewOutput: ViewDelegate { }

@MainActor
final class ColumnPresenter {

	weak var view: (any ColumnView)?

	var interactor: (any ColumnInteractorProtocol)?
}

// MARK: - ViewDelegate
extension ColumnPresenter: ViewDelegate {

	func viewDidChange(state: ViewState) {
		guard state == .didLoad else {
			return
		}
		interactor?.fetchData()
	}
}

// MARK: - ColumnPresenterProtocol
extension ColumnPresenter: ColumnPresenterProtocol {

	func present() {
		view?.display()
	}
}

// MARK: - ColumnViewOutput
extension ColumnPresenter: ColumnViewOutput { }

//
//  ColumnPresenter.swift
//  macOS
//

/// The Column presenter interface.
protocol ColumnPresenterProtocol: AnyObject { }

/// The Column view output interface.
protocol ColumnViewOutput: AnyObject { }

/// The Column presenter.
final class ColumnPresenter {

	var interactor: (any ColumnInteractorProtocol)?

	weak var view: (any ColumnUnitView)?
}

// MARK: - ColumnPresenterProtocol
extension ColumnPresenter: ColumnPresenterProtocol { }

// MARK: - ColumnViewOutput
extension ColumnPresenter: ColumnViewOutput { }

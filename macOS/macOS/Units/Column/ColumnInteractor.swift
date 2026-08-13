//
//  ColumnInteractor.swift
//  macOS
//

/// The Column interactor interface.
protocol ColumnInteractorProtocol: AnyObject { }

/// The Column interactor.
final class ColumnInteractor {

	weak var presenter: (any ColumnPresenterProtocol)?
}

// MARK: - ColumnInteractorProtocol
extension ColumnInteractor: ColumnInteractorProtocol { }

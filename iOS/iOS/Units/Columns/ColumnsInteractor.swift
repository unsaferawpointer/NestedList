//
//  ColumnsInteractor.swift
//  iOS
//

import Foundation

@MainActor protocol ColumnsInteractorProtocol: AnyObject {
	func fetchData()
}

@MainActor final class ColumnsInteractor {

	weak var presenter: (any ColumnsPresenterProtocol)?
}

// MARK: - ColumnsInteractorProtocol
extension ColumnsInteractor: ColumnsInteractorProtocol {

	func fetchData() {
		presenter?.present([.random(), .random(), .random()])
	}
}

//
//  ColumnInteractor.swift
//  iOS
//

import Foundation

@MainActor
protocol ColumnInteractorProtocol: AnyObject {
	func fetchData()
}

@MainActor
final class ColumnInteractor {

	let column: UUID

	weak var presenter: (any ColumnPresenterProtocol)?

	init(column: UUID) {
		self.column = column
	}
}

// MARK: - ColumnInteractorProtocol
extension ColumnInteractor: ColumnInteractorProtocol {

	func fetchData() {
		presenter?.present()
	}
}

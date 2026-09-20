//
//  ColumnUnitAssembly.swift
//  iOS
//

import UIKit

@MainActor
final class ColumnUnitAssembly {

	static func build(column: UUID) -> ColumnCell {
		let cell = ColumnCell()
		configure(cell: cell, column: column)
		return cell
	}

	static func configure(cell: ColumnCell, column: UUID) {
		let interactor = ColumnInteractor(column: column)
		let presenter = ColumnPresenter()

		cell.output = presenter
		presenter.view = cell
		presenter.interactor = interactor
		interactor.presenter = presenter
		cell.configure()
	}
}

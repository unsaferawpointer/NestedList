//
//  ColumnUnitAssembly.swift
//  macOS
//

import AppKit

/// The Column unit assembly.
final class ColumnUnitAssembly {

	/// Builds the Column unit.
	@MainActor
	static func build() -> ColumnViewController {
		let interactor = ColumnInteractor()
		let presenter = ColumnPresenter()
		let viewController = ColumnViewController()

		viewController.output = presenter
		presenter.interactor = interactor
		presenter.view = viewController
		interactor.presenter = presenter

		return viewController
	}
}

//
//  ColumnsUnitAssembly.swift
//  iOS
//

import UIKit

@MainActor
final class ColumnsUnitAssembly {

	static func build() -> ColumnsViewController {
		let interactor = ColumnsInteractor()

		return ColumnsViewController { viewController in
			let presenter = ColumnsPresenter()

			viewController.output = presenter
			presenter.view = viewController
			presenter.interactor = interactor
			interactor.presenter = presenter
		}
	}
}

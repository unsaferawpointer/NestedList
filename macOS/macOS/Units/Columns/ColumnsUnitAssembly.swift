//
//  ColumnsUnitAssembly.swift
//  macOS
//

import AppKit
import CoreModule
import CorePresentation

/// The Columns unit assembly.
final class ColumnsUnitAssembly {

	@MainActor
	static func build(storage: DocumentStorage<DocumentContent>) -> NSViewController {

		let interactor = ColumnsInteractor(storage: storage)
		return ColumnsViewController(storage: storage) { viewController in

			let presenter = ColumnsPresenter()

			viewController.output = presenter
			presenter.view = viewController
			presenter.interactor = interactor
			interactor.presenter = presenter
		}
	}
}

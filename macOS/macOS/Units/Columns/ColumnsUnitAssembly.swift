//
//  ColumnsUnitAssembly.swift
//  Nested List
//
//  Created by Anton Cherkasov on 14.08.2025.
//

import Cocoa
import CoreModule

final class ColumnsUnitAssembly {

	static func build(storage: DocumentStorage<Content>) -> NSViewController {
		let presenter = ColumnsPresenter()
		let interactor = ColumnsInteractor(storage: storage)
		return ColumnsViewController { viewController in
			viewController.output = presenter
			presenter.view = viewController
			presenter.interactor = interactor
			interactor.presenter = presenter
		}
	}
}

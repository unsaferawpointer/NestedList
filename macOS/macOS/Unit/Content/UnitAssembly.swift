//
//  UnitAssembly.swift
//  macOS
//
//  Created by Anton Cherkasov on 16.11.2024.
//

import Cocoa
import CoreModule

final class UnitAssembly {

	static func build(storage: DocumentStorage<Content>) -> NSViewController {
		let presenter = UnitPresenter()
		let interactor = UnitInteractor(storage: storage)
		return ViewController { viewController in
			viewController.output = presenter

			viewController.dropDelegate = presenter
			viewController.cellDelegate = presenter
			viewController.dragDelegate = presenter
			viewController.listDelegate = presenter

			presenter.view = viewController
			presenter.interactor = interactor
			interactor.presenter = presenter
		}
	}
}

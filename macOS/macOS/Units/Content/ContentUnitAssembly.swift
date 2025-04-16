//
//  ContentUnitAssembly.swift
//  macOS
//
//  Created by Anton Cherkasov on 16.11.2024.
//

import Cocoa
import CoreModule

final class ContentUnitAssembly {

	static func build(storage: DocumentStorage<Content>) -> NSViewController {
		let presenter = ContentPresenter()
		let interactor = ContentInteractor(storage: storage)
		return ContentViewController { viewController in
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

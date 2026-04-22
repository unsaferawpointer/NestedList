//
//  ContentUnitAssembly.swift
//  macOS
//
//  Created by Anton Cherkasov on 16.11.2024.
//

import Cocoa
import CoreModule

final class ContentUnitAssembly {

	@MainActor
	static func build(
		for root: UUID? = nil,
		storage: DocumentStorage<Content>,
		configuration: ContentConfiguration
	) -> ContentViewController {

		let interactor = ContentInteractor(storage: storage, root: root)
		return ContentViewController(configuration: configuration) { viewController in

			let router = Router(root: viewController)
			let presenter = ContentPresenter(router: router)

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

//
//  ContentUnitAssembly.swift
//  macOS
//
//  Created by Anton Cherkasov on 16.11.2024.
//

import Cocoa
import CoreModule
import DesignSystem

final class ContentUnitAssembly {

	@MainActor
	static func build(for root: UUID? = nil, storage: DocumentStorage<DocumentContent>) -> ContentViewController {

		let interactor = ContentInteractor(storage: storage, root: root)
		return ContentViewController { viewController in

			let router = ContentRouter(root: viewController, storage: storage)
			let presenter = ContentPresenter(router: router, soundPlayer: SoundPlayer.shared)

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

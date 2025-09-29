//
//  BoardAssembly.swift
//  iOS
//
//  Created by Anton Cherkasov on 22.09.2025.
//

import CoreModule

final class BoardAssembly {

	static func build(router: RouterProtocol, storage: DocumentStorage<Content>) -> BoardViewController {

		let interactor = BoardInteractor(storage: storage)
		let presenter = BoardPresenter()

		return BoardViewController(router: router, storage: storage) { viewController in

			presenter.interactor = interactor
			presenter.view = viewController
			interactor.presenter = presenter
			viewController.viewDelegate = presenter
		}
	}
}

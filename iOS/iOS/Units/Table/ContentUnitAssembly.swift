//
//  ContentUnitAssembly.swift
//  iOS
//
//  Created by Anton Cherkasov on 22.11.2024.
//

import Foundation
import CoreModule
import DesignSystem

final class ContentUnitAssembly {

	static func build(for root: UUID? = nil, storage: DocumentStorage<Content>) -> TableViewController {

		let interactor = ContentUnitInteractor(root: root, storage: storage)

		return TableViewController(id: root) { viewController in

			let router = Router(root: viewController, storage: storage)
			let presenter = ContentPresenter(router: router)
			presenter.interactor = interactor
			presenter.view = viewController
			interactor.presenter = presenter
			viewController.delegate = presenter
			viewController.nestedList.setDelegate(presenter)

		}
	}
}

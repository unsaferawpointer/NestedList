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

	static func build(storage: DocumentStorage<Content>) -> TableViewController {

		let interactor = ContentUnitInteractor(storage: storage)
		let presenter = ContentPresenter()

		return TableViewController { viewController in
			presenter.interactor = interactor
			presenter.view = viewController
			interactor.presenter = presenter
			viewController.delegate = presenter
			viewController.nestedList.setDelegate(presenter)
		}
	}
}

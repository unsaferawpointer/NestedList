//
//  UnitAssembly.swift
//  iOS
//
//  Created by Anton Cherkasov on 22.11.2024.
//

import Foundation
import CoreModule
import DesignSystem

final class UnitAssembly {

	static func build(_ view: UnitView, storage: DocumentStorage<Content>) -> any UnitViewDelegate<UUID> {
		let interactor = UnitInteractor(storage: storage)
		let presenter  = UnitPresenter()
		presenter.interactor = interactor
		presenter.view = view

		interactor.presenter = presenter
		return presenter
	}
}

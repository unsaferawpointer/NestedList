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

	static func build(_ view: ContentView, storage: DocumentStorage<Content>) -> any ContentViewDelegate<UUID> {
		let interactor = ContentUnitInteractor(storage: storage)
		let presenter  = ContentPresenter()
		presenter.interactor = interactor
		presenter.view = view

		interactor.presenter = presenter
		return presenter
	}
}

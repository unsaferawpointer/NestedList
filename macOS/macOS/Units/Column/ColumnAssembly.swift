//
//  ColumnAssembly.swift
//  Nested List
//
//  Created by Anton Cherkasov on 16.08.2025.
//

import Cocoa
import CoreModule

final class ColumnUnitAssembly {

	@MainActor
	static func build(root: UUID, storage: DocumentStorage<Content>) -> NSCollectionViewItem {

		let interactor = ColumnInteractor(root: root, storage: storage)
		let content = ContentUnitAssembly.build(
			for: root,
			storage: storage,
			configuration: .init(drawsBackground: false, hasInsets: false)
		)
		return ColumnViewController(content) { viewController in

			let router = Router(root: viewController)
			let presenter = ColumnPresenter(router: router)

			viewController.output = presenter
			presenter.view = viewController
			presenter.interactor = interactor
			interactor.presenter = presenter
		}
	}

	static func configure(column: ColumnViewController, root: UUID, storage: DocumentStorage<Content>) {

		let presenter = ColumnPresenter(router: Router(root: column))
		let interactor = ColumnInteractor(root: root, storage: storage)

		column.output = presenter
		presenter.view = column
		presenter.interactor = interactor
		interactor.presenter = presenter
	}
}

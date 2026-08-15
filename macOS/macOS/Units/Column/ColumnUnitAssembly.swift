//
//  ColumnUnitAssembly.swift
//  macOS
//

import AppKit
import CoreModule

/// The Column unit assembly.
final class ColumnUnitAssembly {

	@MainActor
	static func build(root: UUID, storage: DocumentStorage<DocumentContent>) -> NSCollectionViewItem {

		let interactor = ColumnInteractor(root: root, storage: storage)
		let content = ContentUnitAssembly.build(
			for: root,
			storage: storage
		)
		return ColumnViewController(content) { viewController in

			let router = ContentRouter(root: viewController, storage: storage)
			let presenter = ColumnPresenter(router: router)

			viewController.output = presenter
			presenter.view = viewController
			presenter.interactor = interactor
			interactor.presenter = presenter
		}
	}

	static func configure(column: ColumnViewController, root: UUID, storage: DocumentStorage<DocumentContent>) {

		let presenter = ColumnPresenter(router: ContentRouter(root: column, storage: storage))
		let interactor = ColumnInteractor(root: root, storage: storage)

		column.output = presenter
		presenter.view = column
		presenter.interactor = interactor
		interactor.presenter = presenter
	}
}

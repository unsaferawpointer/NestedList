//
//  DocumentAssembly.swift
//  iOS
//
//  Created by Anton Cherkasov on 15.09.2025.
//

import CoreModule

final class DocumentAssembly {

	static func build(_ view: DocumentViewController, storage: DocumentStorage<Content>) -> any DocumentViewDelegate {

		let interactor = DocumentInteractor(storage: storage)
		let presenter  = DocumentPresenter()

		view.router = Router(root: view, storage: storage)

		presenter.interactor = interactor
		presenter.view = view
		interactor.presenter = presenter
		return presenter
	}
}

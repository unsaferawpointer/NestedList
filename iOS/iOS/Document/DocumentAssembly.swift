//
//  DocumentAssembly.swift
//  iOS
//
//  Created by Anton Cherkasov on 15.09.2025.
//

import CoreModule

final class DocumentAssembly {

	static func build(_ view: DocumentView, storage: DocumentStorage<Content>) -> any DocumentViewDelegate {

		let interactor = DocumentInteractor(storage: storage)
		let presenter  = DocumentPresenter()

		presenter.interactor = interactor
		presenter.view = view
		interactor.presenter = presenter
		return presenter
	}
}

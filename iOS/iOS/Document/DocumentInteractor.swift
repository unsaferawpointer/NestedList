//
//  DocumentInteractor.swift
//  iOS
//
//  Created by Anton Cherkasov on 14.09.2025.
//

import CoreModule

protocol DocumentInteractorProtocol { }

final class DocumentInteractor {

	// MARK: - DI by Property

	weak var presenter: DocumentPresenterProtocol?

	// MARK: - DI by Initialization

	private let storage: DocumentStorage<Content>

	// MARK: - Initialization

	init(storage: DocumentStorage<Content>) {
		self.storage = storage
	}
}

// MARK: - DocumentInteractorProtocol
extension DocumentInteractor: DocumentInteractorProtocol {

}

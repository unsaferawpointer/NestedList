//
//  ColumnsInteractor.swift
//  Nested List
//
//  Created by Anton Cherkasov on 14.08.2025.
//

import CoreModule

protocol ColumnsInteractorProtocol { }

final class ColumnsInteractor {

	private let storage: DocumentStorage<Content>

	weak var presenter: ColumnsPresenterProtocol?

	// MARK: - Initialization

	init(storage: DocumentStorage<Content>) {
		self.storage = storage
		storage.addObservation(for: self) { [weak self] _, content in
			fatalError()
		}
	}
}

// MARK: - ColumnsInteractorProtocol
extension ColumnsInteractor: ColumnsInteractorProtocol { }

//
//  BoardInteractor.swift
//  iOS
//
//  Created by Anton Cherkasov on 22.09.2025.
//

import CoreModule

protocol BoardInteractorProtocol {
	func fetchData()
}

final class BoardInteractor {

	// MARK: - DI by Property

	weak var presenter: BoardPresenterProtocol?

	// MARK: - DI by Initialization

	private let storage: DocumentStorage<Content>

	// MARK: - Initialization

	init(storage: DocumentStorage<Content>) {
		self.storage = storage
		storage.addObservation(for: self) { [weak self] content in
			guard let self else {
				return
			}
			let ids = content.root.nodes.compactMap(\.id)
			self.presenter?.present(columns: ids)
		}
	}
}

// MARK: - BoardInteractorProtocol
extension BoardInteractor: BoardInteractorProtocol {

	func fetchData() {
		let ids = storage.state.root.nodes.compactMap(\.id)
		presenter?.present(columns: ids)
	}
}

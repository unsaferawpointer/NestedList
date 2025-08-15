//
//  ColumnsInteractor.swift
//  Nested List
//
//  Created by Anton Cherkasov on 14.08.2025.
//

import Foundation
import CoreModule

protocol ColumnsInteractorProtocol {
	func fetchData()
}

final class ColumnsInteractor {

	private let storage: DocumentStorage<Content>

	weak var presenter: ColumnsPresenterProtocol?

	// MARK: - Initialization

	init(storage: DocumentStorage<Content>) {
		self.storage = storage
		storage.addObservation(for: self) { [weak self] _, content in
			self?.presenter?.present(storage.state.root.nodes)
		}
	}
}

// MARK: - ColumnsInteractorProtocol
extension ColumnsInteractor: ColumnsInteractorProtocol {

	func fetchData() {
		presenter?.present(storage.state.root.nodes)
	}
}

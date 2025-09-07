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
	func createNewItem(with text: String) -> UUID
}

final class ColumnsInteractor {

	private let storage: DocumentStorage<Content>

	weak var presenter: ColumnsPresenterProtocol?

	// MARK: - Initialization

	init(storage: DocumentStorage<Content>) {
		self.storage = storage
		storage.addObservation(for: self) { [weak self] content in
			self?.presenter?.present(storage.state.root.nodes)
		}
	}

	deinit {
		storage.removeObserver(self)
	}
}

// MARK: - ColumnsInteractorProtocol
extension ColumnsInteractor: ColumnsInteractorProtocol {

	func fetchData() {
		presenter?.present(storage.state.root.nodes)
	}

	func createNewItem(with text: String) -> UUID {
		let new = Item(uuid: .random, text: text)
		storage.modificate { content in
			content.root.insertItems(with: [new], to: .toRoot)
		}
		return new.id
	}
}

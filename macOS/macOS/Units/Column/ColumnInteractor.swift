//
//  ColumnInteractor.swift
//  Nested List
//
//  Created by Anton Cherkasov on 16.08.2025.
//

import Foundation
import CoreModule

protocol ColumnInteractorProtocol {
	func fetchData()

	func deleteColumn()
}

final class ColumnInteractor {

	let root: UUID

	private let storage: DocumentStorage<Content>

	weak var presenter: ColumnPresenterProtocol?

	// MARK: - Initialization

	init(root: UUID, storage: DocumentStorage<Content>) {
		self.root = root
		self.storage = storage
		storage.addObservation(for: self) { [weak self] _, content in
			guard let item = storage.state.root.node(with: root)?.value else {
				return
			}
			self?.presenter?.present(item)
		}
	}
}

// MARK: - ColumnInteractorProtocol
extension ColumnInteractor: ColumnInteractorProtocol {

	func fetchData() {
		guard let item = storage.state.root.node(with: root)?.value else {
			return
		}
		presenter?.present(item)
	}

	func deleteColumn() {
		storage.modificate { content in
			content.root.deleteItem(root)
		}
	}
}

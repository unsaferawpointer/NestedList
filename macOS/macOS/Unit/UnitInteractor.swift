//
//  UnitInteractor.swift
//  macOS
//
//  Created by Anton Cherkasov on 16.11.2024.
//

import Foundation
import Hierarchy
import CoreModule

protocol UnitInteractorProtocol {
	func fetchData()

	func move(_ ids: [UUID], to destination: Destination<UUID>)
	func validateMovement(_ ids: [UUID], to destination: Destination<UUID>) -> Bool

	func newItem(_ text: String, target: UUID?) -> UUID
	func deleteItems(_ ids: [UUID])
}

final class UnitInteractor {

	private let storage: DocumentStorage<Content>

	weak var presenter: UnitPresenterProtocol?

	// MARK: - Initialization

	init(storage: DocumentStorage<Content>) {
		self.storage = storage
		storage.addObservation(for: self) { [weak self] _, content in
			guard let self else {
				return
			}
			self.presenter?.present(content)
		}
	}
}

// MARK: - UnitInteractorProtocol
extension UnitInteractor: UnitInteractorProtocol {

	func fetchData() {
		presenter?.present(storage.state)
	}

	func move(_ ids: [UUID], to destination: Destination<UUID>) {
		storage.modificate { content in
			content.root.moveItems(with: ids, to: destination)
		}
	}

	func validateMovement(_ ids: [UUID], to destination: Destination<UUID>) -> Bool {
		storage.state.root.validateMoving(ids, to: destination)
	}

	func newItem(_ text: String, target: UUID?) -> UUID {
		let new = Item(uuid: .random, text: text)
		let destination = Destination(target: target)
		storage.modificate { content in
			content.root.insertItems(with: [new], to: destination)
		}
		return new.id
	}

	func deleteItems(_ ids: [UUID]) {
		storage.modificate { content in
			content.root.deleteItems(ids)
		}
	}

}

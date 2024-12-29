//
//  UnitInteractor.swift
//  iOS
//
//  Created by Anton Cherkasov on 22.11.2024.
//

import Foundation
import Hierarchy
import CoreModule

protocol UnitInteractorProtocol {
	func fetchData()

	@discardableResult
	func newItem(_ text: String, target: UUID?) -> UUID
	func deleteItems(_ ids: [UUID])
	func setStatus(_ isDone: Bool, for id: UUID)
	func setText(_ text: String, for id: UUID)
	func item(for id: UUID) -> Item

	func string(for id: UUID) -> String
	func insertStrings(_ strings: [String], to destination: Destination<UUID>)
}

final class UnitInteractor {

	private let storage: DocumentStorage<Content>

	var presenter: UnitPresenterProtocol?

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

	func newItem(_ text: String, target: UUID?) -> UUID {
		let new = Item(uuid: UUID(), text: text, style: .item)
		let destination = Destination(target: target)
		storage.modificate { content in
			content.root.insertItems(with: [new], to: destination)
		}
		return new.id
	}

	func item(for id: UUID) -> Item {
		guard let node = storage.state.root.node(with: id) else {
			fatalError()
		}
		return node.value
	}

	func deleteItems(_ ids: [UUID]) {
		storage.modificate { content in
			content.root.deleteItems(ids)
		}
	}

	func setStatus(_ isDone: Bool, for id: UUID) {
		storage.modificate { content in
			content.root.setProperty(\.isDone, to: isDone, for: [id], downstream: true)
		}
	}

	func setText(_ text: String, for id: UUID) {
		storage.modificate { content in
			content.root.setProperty(\.text, to: text, for: [id])
		}
	}

	func string(for id: UUID) -> String {

		guard let node = storage.state.root.node(with: id) else {
			fatalError("Can`t find node with id = \(id)")
		}

		let formatter = BasicFormatter()

		return formatter.format(node)
	}

	func insertStrings(_ strings: [String], to destination: Hierarchy.Destination<UUID>) {
		let parser = Parser()
		let nodes = strings.flatMap { string in
			parser.parse(from: string)
		}
		storage.modificate { content in
			content.root.insertItems(from: nodes, to: destination)
		}
	}
}

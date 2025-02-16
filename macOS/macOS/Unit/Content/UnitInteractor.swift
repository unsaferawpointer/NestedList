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

	func copy(_ ids: [UUID], to destination: Destination<UUID>)

	func newItem(_ text: String, target: UUID?) -> UUID
	func setStatus(_ status: Bool, for ids: [UUID], moveToEnd: Bool)
	func toggleStatus(for id: UUID, moveToEnd: Bool)
	func setMark(_ isMarked: Bool, for ids: [UUID])
	func setStyle(_ style: Item.Style, for ids: [UUID])
	func set(text: String, note: String?, for id: UUID)
	func deleteNote(for ids: [UUID])
	func addNote(for ids: [UUID])
	func deleteItems(_ ids: [UUID])

	func strings(for ids: [UUID]) -> [String]
	func insertStrings(_ strings: [String], to destination: Destination<UUID>)
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

	func copy(_ ids: [UUID], to destination: Hierarchy.Destination<UUID>) {
		let nodes = storage.state.root.nodes(with: ids)
		let copied = nodes.map { node in
			node.map { item in
				Item(
					uuid: .random,
					isDone: item.isDone,
					text: item.text,
					style: item.style
				)
			}
		}
		storage.modificate { content in
			content.root.insertItems(from: copied, to: destination)
		}
	}

	func newItem(_ text: String, target: UUID?) -> UUID {
		let new = Item(uuid: .random, text: text, style: .item)
		let destination = Destination(target: target)
		storage.modificate { content in
			content.root.insertItems(with: [new], to: destination)
		}
		return new.id
	}

	func setStatus(_ status: Bool, for ids: [UUID], moveToEnd: Bool) {
		storage.modificate { content in
			content.root.setProperty(\.isDone, to: status, for: ids, downstream: true)
			if moveToEnd == false {
				content.root.moveToEnd(ids)
			}
		}
	}

	func toggleStatus(for id: UUID, moveToEnd: Bool) {
		storage.modificate { content in
			let status = content.root.node(with: id)?.value.isDone ?? false
			content.root.setProperty(\.isDone, to: !status, for: [id], downstream: true)
			if moveToEnd && status == false {
				content.root.moveToEnd([id])
			}
		}
	}

	func setMark(_ isMarked: Bool, for ids: [UUID]) {
		storage.modificate { content in
			content.root.setProperty(\.isMarked, to: isMarked, for: ids, downstream: true)
		}
	}

	func setStyle(_ style: CoreModule.Item.Style, for ids: [UUID]) {
		storage.modificate { content in
			content.root.setProperty(\.style, to: style, for: ids, downstream: false)
		}
	}

	func set(text: String, note: String?, for id: UUID) {
		storage.modificate { content in
			content.root.setProperty(\.text, to: text, for: [id])
			content.root.setProperty(\.note, to: note, for: [id])
		}
	}

	func deleteItems(_ ids: [UUID]) {
		storage.modificate { content in
			content.root.deleteItems(ids)
		}
	}

	func strings(for ids: [UUID]) -> [String] {

		let cache = Set(ids)

		let nodes = storage.state.root.nodes(with: ids)
		let copied = nodes.map { node in
			node.map { $0 }
		}

		copied.forEach { node in
			node.deleteDescendants(with: cache)
		}

		let parser = Parser()

		return copied.map { node in
			parser.format(node)
		}
	}

	func insertStrings(_ strings: [String], to destination: Destination<UUID>) {
		let parser = Parser()
		let nodes = strings.flatMap { string in
			parser.parse(from: string)
		}
		storage.modificate { content in
			content.root.insertItems(from: nodes, to: destination)
		}
	}

	func deleteNote(for ids: [UUID]) {
		storage.modificate { content in
			content.root.setProperty(\.note, to: nil, for: ids)
		}
	}

	func addNote(for ids: [UUID]) {
		storage.modificate { content in
			content.root.setProperty(\.note, to: "", for: ids)
		}
	}

}

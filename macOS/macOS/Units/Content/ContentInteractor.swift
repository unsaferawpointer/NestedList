//
//  ContentInteractor.swift
//  macOS
//
//  Created by Anton Cherkasov on 16.11.2024.
//

import Foundation
import Hierarchy
import CoreModule

protocol ContentInteractorProtocol {
	func fetchData()

	func move(_ ids: [UUID], to destination: Destination<UUID>)
	func validateMovement(_ ids: [UUID], to destination: Destination<UUID>) -> Bool

	func copy(_ ids: [UUID], to destination: Destination<UUID>)

	func newItem(_ text: String, target: UUID?) -> UUID
	func setStatus(_ status: Bool, for ids: [UUID], moveToEnd: Bool)
	func toggleStrikethrough(for id: UUID, moveToEnd: Bool)
	func setMark(_ isMarked: Bool, for ids: [UUID], moveToTop: Bool)
	func setStyle(_ style: Item.Style, for ids: [UUID])
	func set(text: String, note: String?, for id: UUID)
	func set(note: String?, for ids: [UUID])
	func deleteItems(_ ids: [UUID])

	func strings(for ids: [UUID]) -> [String]
	func insertStrings(_ strings: [String], to destination: Destination<UUID>)
}

final class ContentInteractor {

	private let storage: DocumentStorage<Content>

	weak var presenter: ContentPresenterProtocol?

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

// MARK: - ContentInteractorProtocol
extension ContentInteractor: ContentInteractorProtocol {

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
				item.copy()
			}
		}
		storage.modificate { content in
			content.root.insertItems(from: copied, to: destination)
		}
	}

	func newItem(_ text: String, target: UUID?) -> UUID {
		let new = Item(uuid: .random, text: text)
		let destination = Destination(target: target)
		storage.modificate { content in
			content.root.insertItems(with: [new], to: destination)
		}
		return new.id
	}

	func setStatus(_ status: Bool, for ids: [UUID], moveToEnd: Bool) {
		storage.modificate { content in
			content.root.setProperty(\.isStrikethrough, to: status, for: ids, downstream: true)
			if moveToEnd && status {
				content.root.moveToEnd(ids)
			}
		}
	}

	func toggleStrikethrough(for id: UUID, moveToEnd: Bool) {
		storage.modificate { content in
			let status = content.root.node(with: id)?.value.isStrikethrough ?? false
			content.root.setProperty(\.isStrikethrough, to: !status, for: [id], downstream: true)
			if moveToEnd && status == false {
				content.root.moveToEnd([id])
			}
		}
	}

	func setMark(_ isMarked: Bool, for ids: [UUID], moveToTop: Bool) {
		storage.modificate { content in
			content.root.setProperty(\.isMarked, to: isMarked, for: ids, downstream: true)
			if moveToTop && isMarked {
				content.root.moveToTop(ids)
			}
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

	func set(note: String?, for ids: [UUID]) {
		storage.modificate { content in
			content.root.setProperty(\.note, to: note, for: ids)
		}
	}
}

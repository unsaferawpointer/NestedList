//
//  ContentInteractor.swift
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
	func newItem(_ text: String, note: String?, isMarked: Bool, style: ItemStyle, target: UUID?) -> UUID
	func deleteItems(_ ids: [UUID])
	func setStatus(_ isStrikethrough: Bool, for ids: [UUID], moveToEnd: Bool)
	func mark(_ isMarked: Bool, ids: [UUID], moveToTop: Bool)
	func setStyle(_ style: ItemStyle, for ids: [UUID])
	func set(_ text: String, note: String?, isMarked: Bool, style: ItemStyle, for id: UUID)
	func item(for id: UUID) -> Item

	func string(for ids: [UUID]) -> String
	func insertStrings(_ strings: [String], to destination: Destination<UUID>)

	func move(ids: [UUID], to destination: Destination<UUID>)
	func validateMovement(_ ids: [UUID], to destination: Destination<UUID>) -> Bool
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

// MARK: - ContentInteractorProtocol
extension UnitInteractor: UnitInteractorProtocol {

	func fetchData() {
		presenter?.present(storage.state)
	}

	func newItem(_ text: String, note: String?, isMarked: Bool, style: ItemStyle, target: UUID?) -> UUID {
		var options = ItemOptions()
		if isMarked {
			options.insert(.marked)
		}
		let new = Item(uuid: UUID(), text: text, note: note, options: options, style: style)
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

	func setStatus(_ isStrikethrough: Bool, for ids: [UUID], moveToEnd: Bool) {
		storage.modificate { content in
			content.root.setProperty(\.isStrikethrough, to: isStrikethrough, for: ids, downstream: true)
			if moveToEnd && isStrikethrough {
				content.root.moveToEnd(ids)
			}
		}
	}

	func mark(_ isMarked: Bool, ids: [UUID], moveToTop: Bool) {
		storage.modificate { content in
			content.root.setProperty(\.isMarked, to: isMarked, for: ids, downstream: true)
			if moveToTop && isMarked {
				content.root.moveToTop(ids)
			}
		}
	}

	func setStyle(_ style: ItemStyle, for ids: [UUID]) {
		storage.modificate { content in
			content.root.setProperty(\.style, to: style, for: ids)
		}
	}

	func set(_ text: String, note: String?, isMarked: Bool, style: ItemStyle, for id: UUID) {
		storage.modificate { content in
			content.root.setProperty(\.text, to: text, for: [id])
			content.root.setProperty(\.note, to: note, for: [id])
			content.root.setProperty(\.isMarked, to: isMarked, for: [id], downstream: true)
			content.root.setProperty(\.style, to: style, for: [id])
		}
	}

	func string(for ids: [UUID]) -> String {

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
		}.joined(separator: "\n")
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

	func move(ids: [UUID], to destination: Destination<UUID>) {
		storage.modificate { content in
			content.root.moveItems(with: ids, to: destination)
		}
	}

	func validateMovement(_ ids: [UUID], to destination: Destination<UUID>) -> Bool {
		storage.state.root.validateMoving(ids, to: destination)
	}
}

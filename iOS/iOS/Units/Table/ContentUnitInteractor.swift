//
//  ContentInteractor.swift
//  iOS
//
//  Created by Anton Cherkasov on 22.11.2024.
//

import Foundation
import Hierarchy
import CoreModule

protocol ContentUnitInteractorProtocol {
	func fetchData()

	@discardableResult
	func newItem(_ text: String, note: String?, isMarked: Bool, style: ItemStyle, target: UUID?) -> UUID
	func deleteItems(_ ids: [UUID])
	func setStatus(_ isStrikethrough: Bool, for ids: [UUID], moveToEnd: Bool)
	func mark(_ isMarked: Bool, ids: [UUID], moveToTop: Bool)
	func setStyle(_ style: ItemStyle, for ids: [UUID])
	func set(_ text: String, note: String?, isMarked: Bool, style: ItemStyle, for id: UUID)
	func item(for id: UUID) -> Item

	func data(of id: UUID) -> Data?
	func string(for ids: [UUID]) -> String
	func insertStrings(_ strings: [String], to destination: Destination<UUID>)
	func insertNodes(_ nodes: [any TreeNode<Item>], to destination: Destination<UUID>)

	func move(ids: [UUID], to destination: Destination<UUID>)
	func validateMovement(_ ids: [UUID], to destination: Destination<UUID>) -> Bool
}

final class ContentUnitInteractor {

	private let storage: DocumentStorage<Content>

	var presenter: ContentPresenterProtocol?

	var base: CommonInteractorProtocol

	// MARK: - Internal State

	private var root: UUID?

	// MARK: - Initialization

	init(root: UUID?, storage: DocumentStorage<Content>) {
		self.storage = storage
		self.base = CommonInteractor(storage: storage)
		self.root = root
		storage.addObservation(for: self) { [weak self] content in
			guard let self else {
				return
			}
			let nodes = content.root.children(of: self.root)
			self.presenter?.present(nodes)
		}
	}

	deinit {
		storage.removeObserver(self)
	}
}

// MARK: - ContentInteractorProtocol
extension ContentUnitInteractor: ContentUnitInteractorProtocol {

	func fetchData() {
		presenter?.present(storage.state.root.children(of: root))
	}

	func newItem(_ text: String, note: String?, isMarked: Bool, style: ItemStyle, target: UUID?) -> UUID {
		let destination = Destination(target: target)
		return base.newItem(
			text,
			isStrikethrough: nil,
			note: note,
			isMarked: isMarked,
			style: style,
			target: destination.id
		)
	}

	func item(for id: UUID) -> Item {
		guard let node = storage.state.root.node(with: id) else {
			fatalError()
		}
		return node.value
	}

	func deleteItems(_ ids: [UUID]) {
		base.deleteItems(ids)
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

	func data(of id: UUID) -> Data? {
		guard let node = storage.state.root.node(with: id) else {
			return nil
		}
		return try? JSONEncoder().encode(node)
	}

	func insertStrings(_ strings: [String], to destination: Destination<UUID>) {
		base.insertStrings(strings, to: destination.relative(to: root))
	}

	func insertNodes(_ nodes: [any TreeNode<Item>], to destination: Destination<UUID>) {
		storage.modificate { content in
			content.root.insertItems(from: nodes, to: destination.relative(to: root))
		}
	}

	func move(ids: [UUID], to destination: Destination<UUID>) {
		base.move(ids, to: destination.relative(to: root))
	}

	func validateMovement(_ ids: [UUID], to destination: Destination<UUID>) -> Bool {
		base.validateMovement(ids, to: destination.relative(to: root))
	}
}

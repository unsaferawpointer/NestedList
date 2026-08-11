//
//  CommonInteractor.swift
//  CoreModule
//
//  Created by Anton Cherkasov on 30.08.2025.
//

import Foundation
import Hierarchy

public protocol CommonInteractorProtocol {
	func newItem(with properties: ItemProperties, target: UUID?) -> UUID
	func deleteItems(_ ids: [UUID])

	func validateMovement(_ ids: [UUID], to destination: Destination<UUID>) -> Bool
	func move(_ ids: [UUID], to destination: Destination<UUID>)
	func insertStrings(_ strings: [String], to destination: Destination<UUID>)
	func setStatus(_ isStrikethrough: Bool, for ids: [UUID], moveToEnd: Bool)
	func set(text: String, note: String?, for id: UUID)
	func copy(_ ids: [UUID], to destination: Destination<UUID>)
	func toggleStrikethrough(for id: UUID, moveToEnd: Bool)
	func insertItems(_ data: [Data], to destination: Destination<UUID>)
	func insertNodes(_ nodes: [any TreeNode<Item>], to destination: Destination<UUID>)
	func nodes(for ids: [UUID]) -> [any TreeNode<Item>]
	func data(of id: UUID) -> Data?
	func string(for ids: [UUID]) -> String

	func setProperty<T>(
		_ property: WritableKeyPath<Item, T>,
		to value: T,
		for ids: [UUID],
		downstream: Bool
	)
}

public final class CommonInteractor {

	private let storage: DocumentStorage<DocumentContent>

	public init(storage: DocumentStorage<DocumentContent>) {
		self.storage = storage
	}
}

// MARK: - CommonInteractorProtocol
extension CommonInteractor: CommonInteractorProtocol {

	public func newItem(with properties: ItemProperties, target: UUID?) -> UUID {
		let newItem = Item(uuid: UUID(), properties: properties)
		let destination = Destination(target: target)
		storage.modificate { content in
			content.insertItems(with: [newItem], to: destination)
		}
		return newItem.id
	}

	public func validateMovement(_ ids: [UUID], to destination: Destination<UUID>) -> Bool {
		storage.state.validateMoving(ids, to: destination)
	}

	public func move(_ ids: [UUID], to destination: Destination<UUID>) {
		storage.modificate { content in
			content.moveItems(with: ids, to: destination)
		}
	}

	public func deleteItems(_ ids: [UUID]) {
		storage.modificate { content in
			content.deleteItems(ids)
		}
	}

	public func insertStrings(_ strings: [String], to destination: Destination<UUID>) {
		let parser = Parser()
		let nodes = strings.flatMap { string in
			parser.parse(from: string)
		}
		storage.modificate { content in
			content.insertItems(from: nodes, to: destination)
		}
	}

	public func setStatus(_ isStrikethrough: Bool, for ids: [UUID], moveToEnd: Bool) {
		storage.modificate { content in
			content.setProperty(\.isStrikethrough, to: isStrikethrough, for: ids, downstream: true)
			if moveToEnd && isStrikethrough {
				content.moveToEnd(ids)
			}
		}
	}

	public func set(text: String, note: String?, for id: UUID) {
		storage.modificate { content in
			content.setProperty(\.text, to: text, for: [id])
			content.setProperty(\.note, to: note, for: [id])
		}
	}

	public func copy(_ ids: [UUID], to destination: Destination<UUID>) {
		storage.modificate { content in
			content.copy(ids: ids, to: destination)
		}
	}

	public func toggleStrikethrough(for id: UUID, moveToEnd: Bool) {
		storage.modificate { content in
			let status = content.allMatch(id: id, keyPath: \.isStrikethrough, equalsTo: true)
			content.setProperty(\.isStrikethrough, to: !status, for: [id], downstream: true)
			if moveToEnd && status == false {
				content.moveToEnd([id])
			}
		}
	}

	public func insertItems(_ data: [Data], to destination: Destination<UUID>) {
		storage.modificate { content in
			content.insertItems(from: data, to: destination)
		}
	}

	public func insertNodes(_ nodes: [any TreeNode<Item>], to destination: Destination<UUID>) {
		storage.modificate { content in
			content.insertItems(from: nodes, to: destination)
		}
	}

	public func data(of id: UUID) -> Data? {
		storage.state.encode(id: id)
	}

	public func nodes(for ids: [UUID]) -> [any TreeNode<Item>] {
		return storage.state.copiedDisjointSubtrees(with: ids)
	}

	public func string(for ids: [UUID]) -> String {
		let copied = storage.state.copiedDisjointSubtrees(with: ids)
		let parser = Parser()

		return copied.map { node in
			parser.format(node)
		}.joined(separator: "\n")
	}

	public func setProperty<T>(
		_ property: WritableKeyPath<Item, T>,
		to value: T,
		for ids: [UUID],
		downstream: Bool
	) {
		storage.modificate {
			$0.setProperty(property, to: value, for: ids, downstream: downstream)
		}
	}
}

//
//  DocumentContent.swift
//  CoreModule
//
//  Created by Anton Cherkasov on 16.11.2024.
//

import Foundation
import Hierarchy

public struct DocumentContent {

	public var uuid: UUID?

	public var view: ContentView

	private var store: NodeStore<Item>

	// MARK: - Initialization

	public init(
		uuid: UUID?,
		nodes: [DocumentNode] = [],
		view: ContentView = .list
	) {
		self.uuid = uuid
		self.store = NodeStore<Item>(hierarchy: nodes)
		self.view = view
	}
}

// MARK: - Subscript
public extension DocumentContent {

	subscript(id: UUID) -> Item? {
		return store[id]
	}
}

// MARK: - Public Interface
public extension DocumentContent {

	func node(with id: UUID) -> DocumentNode? {
		store.node(with: id, type: DocumentNode.self)
	}

	func snapshot() -> Snapshot<Item> {
		store.snapshot()
	}

	func insertItems(with contents: [Item], to destination: Destination<UUID>) throws {
		try store.insert(contents, at: destination)
	}

	func insertItems(from data: [any TreeNode<Item>], to destination: Destination<UUID>) throws {
		try store.insertItems(from: data, to: destination)
	}

	func validateMoving(_ ids: [UUID], to destination: Destination<UUID>) -> Bool {
		store.validateMoving(ids, to: destination)
	}

	func moveItems(with ids: [UUID], to destination: Destination<UUID>) throws {
		try store.moveItems(withIDs: ids, to: destination)
	}

	func validateMovingForward(id: UUID) -> Bool {
		store.validateMovingForward(id)
	}

	func validateMovingBackward(id: UUID) -> Bool {
		store.validateMovingBackward(id)
	}

	func moveForward(id: UUID) throws {
		try store.moveForward(id)
	}

	func moveBackward(id: UUID) throws {
		try store.moveBackward(id)
	}

	func moveToEnd(_ ids: [UUID]) throws {
		try store.moveToEnd(ids)
	}

	func invalidTargets(movingItems ids: Set<UUID>) -> Set<UUID> {
		store.descendantIDs(including: ids)
	}

	func deleteItems(_ ids: [UUID]) {
		store.deleteItems(withIDs: ids)
	}

	func parent(for id: UUID?) -> Item? {
		guard let id else {
			return nil
		}
		return store.parent(of: id)
	}

	func setProperty<T>(
		_ keyPath: WritableKeyPath<Item, T>,
		to value: T,
		for ids: [UUID],
		downstream: Bool = false
	) {
		store.setProperty(keyPath, to: value, for: ids, downstream: downstream)
	}

	func copiedDisjointSubtrees(with ids: [UUID]) -> [any TreeNode<Item>] {
		store.copiedDisjointSubtrees(with: ids)
	}

	func tree() -> [any TreeNode<Item>] {
		store.nodes(type: DocumentNode.self)
	}

	func copy(ids: [UUID], to destination: Destination<UUID>) throws {
		try store.copy(ids: ids, to: destination)
	}

	func allMatch<T: Equatable>(id: UUID, keyPath: KeyPath<Item, T>, equalsTo value: T) -> Bool {
		store.allMatch(id: id, keyPath: keyPath, equalsTo: value)
	}
}

// MARK: - Templates
public extension DocumentContent {

	static var empty: DocumentContent {
		return .init(uuid: UUID())
	}
}

// MARK: - Equatable
extension DocumentContent: Equatable { }

// MARK: - Codable
extension DocumentContent: Codable {

	enum CodingKeys: CodingKey {
		case items
		case view
		case uuid
	}

	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		let nodes = try container.decode([DocumentNode].self, forKey: .items)
		let view = try container.decodeIfPresent(ContentView.self, forKey: .view) ?? .list
		let uuid = try? container.decodeIfPresent(UUID.self, forKey: .uuid)
		self.init(uuid: uuid, nodes: nodes, view: view)
	}

	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(store.nodes(type: DocumentNode.self), forKey: .items)
		try container.encode(view, forKey: .view)
		try container.encode(uuid ?? UUID(), forKey: .uuid)
	}
}

// MARK: - Nested structs
public extension DocumentContent {

	enum ContentView: Int, Codable {
		case list = 0
		case columns = 1
	}
}

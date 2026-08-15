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

	private var root: NodeStore<Item>

	// MARK: - Initialization

	public init(
		uuid: UUID?,
		nodes: [any TreeNode<Item>] = [],
		view: ContentView = .list
	) {
		self.uuid = uuid
		self.root = NodeStore<Item>(hierarchy: nodes)
		self.view = view
	}
}

// MARK: - Subscript
public extension DocumentContent {

	subscript(id: UUID) -> Item? {
		return root[id]
	}
}

// MARK: - Public Interface
public extension DocumentContent {

	func snapshot() -> Snapshot<Item> {
		root.snapshot()
	}

	func insertItems(with contents: [Item], to destination: Destination<UUID>) {
		root.insertItems(with: contents, to: destination)
	}

	func insertItems(from data: [any TreeNode<Item>], to destination: Destination<UUID>) {
		root.insertItems(from: data, to: destination)
	}

	func insertItems(from data: [Data], to destination: Destination<UUID>) {
		root.insertItems(from: data, to: destination)
	}

	func validateMoving(_ ids: [UUID], to destination: Destination<UUID>) -> Bool {
		root.validateMoving(ids, to: destination)
	}

	func moveItems(with ids: [UUID], to destination: Destination<UUID>) {
		root.moveItems(with: ids, to: destination)
	}

	func validateMovingForward(id: UUID) -> Bool {
		root.validateMovingForward(id)
	}

	func validateMovingBackward(id: UUID) -> Bool {
		root.validateMovingBackward(id)
	}

	func moveForward(id: UUID) {
		root.moveForward(id)
	}

	func moveBackward(id: UUID) {
		root.moveBackward(id)
	}

	func moveToEnd(_ ids: [UUID]) {
		root.moveToEnd(ids)
	}

	func invalidTargets(movingItems ids: Set<UUID>) -> Set<UUID> {
		root.invalidTargets(movingItems: ids)
	}

	func deleteItems(_ ids: [UUID]) {
		root.deleteItems(ids)
	}

	func parent(for id: UUID?) -> Item? {
		root.parent(for: id)
	}

	func setProperty<T>(
		_ keyPath: WritableKeyPath<Item, T>,
		to value: T,
		for ids: [UUID],
		downstream: Bool = false
	) {
		root.setProperty(keyPath, to: value, for: ids, downstream: downstream)
	}

	func copiedDisjointSubtrees(with ids: [UUID]) -> [any TreeNode<Item>] {
		root.copiedDisjointSubtrees(with: ids)
	}

	func tree() -> [any TreeNode<Item>] {
		root.nodes
	}

	func copy(ids: [UUID], to destination: Destination<UUID>) {
		root.copy(ids: ids, to: destination)
	}

	func allMatch<T: Equatable>(id: UUID, keyPath: KeyPath<Item, T>, equalsTo value: T) -> Bool {
		root.allMatch(id: id, keyPath: keyPath, equalsTo: value)
	}

	func encode(id: UUID) -> Data? {
		root.encode(id: id)
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
		let nodes = try container.decode([Node<Item>].self, forKey: .items)
		let view = try container.decodeIfPresent(ContentView.self, forKey: .view) ?? .list
		let uuid = try? container.decodeIfPresent(UUID.self, forKey: .uuid)
		self.init(uuid: uuid, nodes: nodes, view: view)
	}

	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(root.nodes, forKey: .items)
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

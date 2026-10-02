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

	private var store: MirrorStore<ItemContent, UUID>

	// MARK: - Initialization

	public init(
		uuid: UUID?,
		nodes: [DocumentNode<Item>] = [],
		view: ContentView = .list
	) {
		self.uuid = uuid
		self.store = try! MirrorStore<ItemContent, UUID>(hierarchy: nodes)
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

	func node(with id: UUID) -> DocumentNode<Item>? {
		store.node(with: id, type: DocumentNode<Item>.self)
	}

	func snapshot() -> Snapshot<Item> {
		store.snapshot()
	}

	func insertItems(with contents: [Item], to destination: Destination<UUID>) throws {
		let containers = contents.map {
			Container.item(id: $0.id, content: $0.content)
		}
		try store.insert(containers, at: destination)
	}

	func insertItems(from data: [any TreeNode<Item>], to destination: Destination<UUID>) throws {
		let containers: [ContainerNode] = data.map { node in
			node.map { value in
				Container.item(id: value.id, content: value.content)
			}
		}
		try store.insertItems(from: containers, to: destination)
	}

	func validateMoving(_ ids: [UUID], to destination: Destination<UUID>) -> Bool {
		store.canMoveItems(ids, to: destination)
	}

	func moveItems(with ids: [UUID], to destination: Destination<UUID>) throws {
		try store.moveItems(ids, to: destination)
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
		store.deleteItems(ids)
	}

	func parent(for id: UUID?) -> UUID? {
		guard let id else {
			return nil
		}
		return store.parent(of: id)
	}

	func setProperty<T>(
		_ keyPath: WritableKeyPath<ItemContent, T>,
		to value: T,
		for ids: [UUID],
		downstream: Bool = false
	) {
		store.set(keyPath, to: value, for: ids, includingDescendants: downstream)
	}

	func copiedDisjointSubtrees(with ids: [UUID]) -> [any TreeNode<Item>] {
		store.copiedDisjointSubtrees(with: ids)
	}

	func tree() -> [any TreeNode<Item>] {
		store.nodes(type: DocumentNode<Item>.self)
	}

	func copy(ids: [UUID], to destination: Destination<UUID>) throws {
		let copied = store.copiedDisjointSubtrees(with: ids)
		try insertItems(from: copied, to: destination)
	}

	func allMatch<T: Equatable>(id: UUID, keyPath: KeyPath<ItemContent, T>, equalsTo value: T) -> Bool {
		let resolvedKeyPath = (\Resolved<ItemContent, UUID>.content).appending(path: keyPath)
		return store.allMatch(id: id, keyPath: resolvedKeyPath, equalsTo: value)
	}
}

// MARK: - Private helpers
private struct ContainerNode: TreeNode {

	var value: Container<ItemContent, UUID>
	let children: [ContainerNode]

	init(value: Container<ItemContent, UUID>, children: [ContainerNode]) {
		self.value = value
		self.children = children
	}
}

private typealias StoredDocumentNode = DocumentNode<Container<ItemContent, UUID>>

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
		let version: Version? = if let key = CodingUserInfoKey.documentVersion {
			decoder.userInfo[key] as? Version
		} else {
			nil
		}
		let nodes: [StoredDocumentNode]

		if version?.major == 1 || version?.major == 2 {
			let legacyNodes = try container.decode([DocumentNode<Item>].self, forKey: .items)
			nodes = legacyNodes.map { node in
				node.map { value in
					Container.item(id: value.id, content: value.content)
				}
			}
		} else {
			nodes = try container.decode([StoredDocumentNode].self, forKey: .items)
		}
		let view = try container.decodeIfPresent(ContentView.self, forKey: .view) ?? .list
		let uuid = try? container.decodeIfPresent(UUID.self, forKey: .uuid)
		self.uuid = uuid
		self.view = view
		self.store = try MirrorStore<ItemContent, UUID>(hierarchy: nodes)
	}

	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(store.storedNodes(type: StoredDocumentNode.self), forKey: .items)
		try container.encode(view, forKey: .view)
		try container.encode(uuid ?? UUID(), forKey: .uuid)
	}
}

// MARK: - Nested structs
public extension DocumentContent {

	enum ContentView {
		case list
		case columns
		case unknown(Int)
	}
}

// MARK: - RawRepresentable
extension DocumentContent.ContentView: RawRepresentable {

	public init?(rawValue: Int) {
		switch rawValue {
		case 0: self = .list
		case 1: self = .columns
		default: self = .unknown(rawValue)
		}
	}

	public var rawValue: Int {
		switch self {
		case .list: 0
		case .columns: 1
		case let .unknown(rawValue): rawValue
		}
	}
}

// MARK: - Equatable
extension DocumentContent.ContentView: Equatable { }

// MARK: - Codable
extension DocumentContent.ContentView: Codable { }

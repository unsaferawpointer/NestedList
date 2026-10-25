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

	private var store: MirrorStore<ItemContent, UUID>

	// MARK: - Initialization

	public init(
		uuid: UUID?,
		nodes: [DocumentNode<Item>] = []
	) {
		self.uuid = uuid
		self.store = try! MirrorStore<ItemContent, UUID>(hierarchy: nodes)
	}

	/// Restores an independent working tree, validating the stored hierarchy.
	public init(dto: DocumentContentDTO) throws {
		self.uuid = dto.uuid
		self.store = try MirrorStore<ItemContent, UUID>(hierarchy: dto.items)
	}
}

// MARK: - File representation
public extension DocumentContent {

	/// Exports stored containers without resolving mirror references.
	func exportContent() -> DocumentContentDTO {
		DocumentContentDTO(
			uuid: uuid,
			items: store.storedNodes(type: DocumentNode<Container<ItemContent, UUID>>.self)
		)
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

	func insertMirror(reference: UUID, to destination: Destination<UUID>) throws -> UUID {
		try store.insertMirror(reference: reference, to: destination)
	}

	func mirrorSourceIDs(to destination: Destination<UUID>) -> Set<UUID> {
		store.mirrorSourceIDs(to: destination)
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

	public init(from decoder: Decoder) throws {
		try self.init(dto: DocumentContentDTO(from: decoder))
	}

	public func encode(to encoder: Encoder) throws {
		try exportContent().encode(to: encoder)
	}
}

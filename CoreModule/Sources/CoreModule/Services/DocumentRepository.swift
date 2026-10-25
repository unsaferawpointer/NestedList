//
//  DocumentRepository.swift
//  CoreModule
//

import Foundation
import Hierarchy

/// Owns the mutable working tree for a single document.
///
/// File content is imported and exported as independent values. Access to the
/// repository must be serialized by its owner.
public final class DocumentRepository {

	public private(set) var uuid: UUID?

	private var store: MirrorStore<ItemContent, UUID>

	// MARK: - Initialization

	public init(uuid: UUID? = UUID()) {
		self.uuid = uuid
		self.store = MirrorStore()
	}

	public init(dto: DocumentContentDTO) throws {
		self.store = try MirrorStore(hierarchy: dto.items)
		self.uuid = dto.uuid
	}
}

// MARK: - File representation
public extension DocumentRepository {

	/// Exports stored containers without resolving mirror references.
	func exportContent() -> DocumentContentDTO {
		DocumentContentDTO(
			uuid: uuid,
			items: store.storedNodes(type: DocumentNode<Container<ItemContent, UUID>>.self)
		)
	}

	/// Replaces the working tree only after the new hierarchy passes validation.
	func replaceContent(_ content: DocumentContentDTO) throws {
		let newStore = try MirrorStore<ItemContent, UUID>(hierarchy: content.items)
		store = newStore
		uuid = content.uuid
	}
}

// MARK: - Reading
public extension DocumentRepository {

	subscript(id: UUID) -> Item? {
		store[id]
	}

	func node(with id: UUID) -> DocumentNode<Item>? {
		store.node(with: id, type: DocumentNode<Item>.self)
	}

	func snapshot() -> Snapshot<Item> {
		store.snapshot()
	}

	func parent(for id: UUID?) -> UUID? {
		guard let id else {
			return nil
		}
		return store.parent(of: id)
	}

	func tree() -> [any TreeNode<Item>] {
		store.nodes(type: DocumentNode<Item>.self)
	}

	func copiedDisjointSubtrees(with ids: [UUID]) -> [any TreeNode<Item>] {
		store.copiedDisjointSubtrees(with: ids)
	}

	func allMatch<T: Equatable>(id: UUID, keyPath: KeyPath<ItemContent, T>, equalsTo value: T) -> Bool {
		let resolvedKeyPath = (\Resolved<ItemContent, UUID>.content).appending(path: keyPath)
		return store.allMatch(id: id, keyPath: resolvedKeyPath, equalsTo: value)
	}
}

// MARK: - Validation
public extension DocumentRepository {

	func mirrorSourceIDs(to destination: Destination<UUID>) -> Set<UUID> {
		store.mirrorSourceIDs(to: destination)
	}

	func validateMoving(_ ids: [UUID], to destination: Destination<UUID>) -> Bool {
		store.canMoveItems(ids, to: destination)
	}

	func validateMovingForward(id: UUID) -> Bool {
		store.validateMovingForward(id)
	}

	func validateMovingBackward(id: UUID) -> Bool {
		store.validateMovingBackward(id)
	}

	func invalidTargets(movingItems ids: Set<UUID>) -> Set<UUID> {
		store.descendantIDs(including: ids)
	}
}

// MARK: - Editing
public extension DocumentRepository {

	func insertItems(with contents: [Item], to destination: Destination<UUID>) throws {
		let containers = contents.map {
			Container.item(id: $0.id, content: $0.content)
		}
		try store.insert(containers, at: destination)
	}

	func insertItems(from data: [any TreeNode<Item>], to destination: Destination<UUID>) throws {
		let containers: [DocumentNode<Container<ItemContent, UUID>>] = data.map { node in
			node.map { value in
				Container.item(id: value.id, content: value.content)
			}
		}
		try store.insertItems(from: containers, to: destination)
	}

	func insertMirror(reference: UUID, to destination: Destination<UUID>) throws -> UUID {
		try store.insertMirror(reference: reference, to: destination)
	}

	func moveItems(with ids: [UUID], to destination: Destination<UUID>) throws {
		try store.moveItems(ids, to: destination)
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

	func deleteItems(_ ids: [UUID]) {
		store.deleteItems(ids)
	}

	func setProperty<T>(
		_ keyPath: WritableKeyPath<ItemContent, T>,
		to value: T,
		for ids: [UUID],
		downstream: Bool = false
	) {
		store.set(keyPath, to: value, for: ids, includingDescendants: downstream)
	}

	func copy(ids: [UUID], to destination: Destination<UUID>) throws {
		let copied = store.copiedDisjointSubtrees(with: ids)
		try insertItems(from: copied, to: destination)
	}
}

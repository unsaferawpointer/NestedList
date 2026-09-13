//
//  MirrorStore.swift
//  Hierarchy
//
//  Created by Anton Cherkasov on 02.09.2026.
//

import Foundation

public final class MirrorStore<Content: Hashable, ID: RandomizableIdentifier> {

	private let base: NodeStore<Container<Content, ID>>

	// MARK: - Initialization

	public init() {
		self.base = NodeStore()
	}

	public init<T: TreeNode>(hierarchy: [T]) where T.Value == Container<Content, ID> {
		self.base = NodeStore(hierarchy: hierarchy)
		validateStorageConsistency()
	}
}

// MARK: - MirrorStoring
extension MirrorStore: MirrorStoring {

	public var identifiers: Set<ID> {
		base.identifiers
	}

	// MARK: - Subscripts

	public subscript(id: ID) -> Resolved<Content, ID>? {
		item(with: id)
	}

	public func parent(of id: ID) -> ID? {
		base.parent(of: id)
	}

	public func children(of parent: ID?) -> [ID] {
		base.children(of: parent)
	}

	public func insert<S: Sequence>(
		_ items: S,
		at destination: Destination<ID>
	) throws(NodeStoreError) where S.Element == Resolved<Content, ID> {
		if let destinationID = destination.id {
			guard let container = base[destinationID] else {
				throw .missingNode
			}
			guard case .item = container else {
				return
			}
		}
		try base.insert(
			items.map {
				.item(id: $0.id, content: $0.content)
			},
			at: destination
		)
	}

	public func moveItems<S: Sequence>(
		_ ids: S,
		to destination: Destination<ID>
	) throws(NodeStoreError) where S.Element == ID {
		guard canMoveItems(ids, to: destination) else {
			return
		}
		try base.moveItems(ids, to: destination)
	}

	public func canMoveItems<S: Sequence>(
		_ ids: S,
		to destination: Destination<ID>
	) -> Bool where S.Element == ID {
		let identifiers = Array(ids)
		guard base.canMoveItems(identifiers, to: destination) else {
			return false
		}

		guard let destinationID = destination.id else {
			return true
		}

		guard case .item = base[destinationID] else {
			return false
		}

		guard let ancestorIDs = ancestorIDs(including: destinationID) else {
			return false
		}

		let movedIDs = base.descendantIDs(including: Set(identifiers))

		return movedIDs.allSatisfy { id in
			guard case let .mirror(_, reference) = base[id] else {
				return true
			}
			return !ancestorIDs.contains(reference)
		}
	}

	public func deleteItems<S: Sequence>(_ ids: S) where S.Element == ID {
		let identifiers = Array(ids)
		let subtreeIDs = base.descendantIDs(including: Set(identifiers))
		let originalIDs = subtreeIDs.reduce(into: Set<ID>()) { result, id in
			guard case .item = base[id] else {
				return
			}
			result.insert(id)
		}

		guard !originalIDs.isEmpty else {
			base.deleteItems(identifiers)
			return
		}

		let externalMirrorIDs = base.identifiers.subtracting(subtreeIDs).filter { id in
			guard case let .mirror(_, reference) = base[id] else {
				return false
			}
			return originalIDs.contains(reference)
		}

		base.deleteItems(identifiers + Array(externalMirrorIDs))
	}

	public func set<T>(
		_ keyPath: WritableKeyPath<Content, T>,
		to value: T,
		for ids: [ID],
		includingDescendants: Bool
	) {
		let selectedIDs = Set(ids)
		let targetIDs = includingDescendants
			? base.descendantIDs(including: selectedIDs)
			: selectedIDs

		let originalIDs = Set(
			targetIDs.compactMap {
				base[$0]?.itemID
			}
		)

		let itemKeyPath = (\Container<Content, ID>.itemContent).appending(path: keyPath)
		base.set(
			itemKeyPath,
			to: value,
			for: Array(originalIDs),
			includingDescendants: false
		)
	}
}

// MARK: - Storage Consistency
private extension MirrorStore {

	func validateStorageConsistency() {
		while true {
			let invalidIDs = base.identifiers.filter { id in
				guard case let .mirror(_, reference) = base[id] else {
					return false
				}
				guard case .item = base[reference] else {
					return true
				}
				guard base.children(of: id).isEmpty else {
					return true
				}
				guard let ancestorIDs = base.ancestorIDs(including: id) else {
					return true
				}
				return ancestorIDs.contains(reference)
			}

			guard !invalidIDs.isEmpty else {
				return
			}
			base.deleteItems(invalidIDs)
		}
	}
}

// MARK: - Mirror Interface
public extension MirrorStore {

	func insertMirror(
		for ids: [ID],
		to destination: Destination<ID>
	) throws(NodeStoreError) -> [ID] {
		guard let references = mirrorReferences(for: ids) else {
			return []
		}
		if !isValidMirrorDestination(for: references, at: destination) {
			guard let destinationID = destination.id, base[destinationID] == nil else {
				return []
			}
		}
		let inserted: [Container<Content, ID>] = references.map {
			.mirror(id: ID.random(), reference: $0)
		}
		try base.insert(inserted, at: destination)
		return inserted.map(\.id)
	}

	func canInsertMirror(
		for ids: [ID],
		to destination: Destination<ID>
	) -> Bool {
		guard let references = mirrorReferences(for: ids) else {
			return false
		}
		return isValidMirrorDestination(for: references, at: destination)
	}
}

// MARK: - Helpers
private extension MirrorStore {

	func mirrorReferences(for ids: [ID]) -> [ID]? {
		let references = ids.compactMap { (id: ID) -> ID? in
			guard let container = base[id] else {
				return nil
			}
			return container.reference ?? id
		}
		guard references.count == ids.count else {
			return nil
		}
		return references
	}

	func isValidMirrorDestination(
		for references: [ID],
		at destination: Destination<ID>
	) -> Bool {
		guard let destinationID = destination.id else {
			return true
		}
		guard case .item = base[destinationID] else {
			return false
		}

		guard let ancestorIDs = ancestorIDs(including: destinationID) else {
			return false
		}

		return ancestorIDs.isDisjoint(with: references)
	}

	func item(with id: ID) -> Resolved<Content, ID>? {
		guard let container = base[id] else {
			return nil
		}
		switch container {
		case let .item(_, content):
			return Resolved(id: id, content: content)
		case let .mirror(_, reference):
			guard case let .item(_, content) = base[reference] else {
				fatalError("Link to non-item")
			}
			return Resolved(id: id, content: content, isMirror: true)
		}
	}
}

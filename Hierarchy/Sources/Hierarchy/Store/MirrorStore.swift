//
//  MirrorStore.swift
//  Hierarchy
//
//  Created by Anton Cherkasov on 02.09.2026.
//

import Foundation

public final class MirrorStore<Value: MutableIdentifiable & Hashable> where Value.ID: RandomizableIdentifier {

	typealias ID = Value.ID

	private let base: any NodeStoring<Container<Value>>

	// MARK: - Initialization

	public init(base: any NodeStoring<Container<Value>>) {
		self.base = base
	}
}

// MARK: - MirrorStoring
extension MirrorStore: MirrorStoring {

	public var identifiers: Set<Value.ID> {
		base.identifiers
	}

	// MARK: - Subscripts

	public subscript(id: Value.ID) -> Resolved<Value, Value.ID>? {
		item(with: id)
	}

	public func parent(of id: Value.ID) -> Value.ID? {
		base.parent(of: id)
	}

	public func children(of parent: Value.ID?) -> [Value.ID] {
		base.children(of: parent)
	}

	public func insert<S: Sequence>(
		_ items: S,
		at destination: Destination<Value.ID>
	) throws(NodeStoreError) where S.Element == Value {
		try base.insert(
			items.lazy.map {
				.item(value: $0)
			},
			at: destination
		)
	}

	public func moveItems<S: Sequence>(
		_ ids: S,
		to destination: Destination<Value.ID>
	) throws(NodeStoreError) where S.Element == Value.ID {
		guard canMoveItems(ids, to: destination) else {
			return
		}
		try base.moveItems(ids, to: destination)
	}

	public func canMoveItems<S: Sequence>(
		_ ids: S,
		to destination: Destination<Value.ID>
	) -> Bool where S.Element == Value.ID {
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

	public func deleteItems<S: Sequence>(_ ids: S) where S.Element == Value.ID {
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
		_ keyPath: WritableKeyPath<Value, T>,
		to value: T,
		for ids: [Value.ID],
		includingDescendants: Bool
	) {
		let selectedIDs = Set(ids)
		let targetIDs = includingDescendants
			? base.descendantIDs(including: selectedIDs)
			: selectedIDs

		let originalIDs = Set(
			targetIDs.compactMap {
				item(with: $0)?.content.id
			}
		)

		let itemKeyPath = (\Container<Value>.itemValue).appending(path: keyPath)
		base.set(
			itemKeyPath,
			to: value,
			for: Array(originalIDs),
			includingDescendants: false
		)
	}
}

// MARK: - Mirror Interface
public extension MirrorStore {

	func insertMirror(
		for ids: [Value.ID],
		to destination: Destination<Value.ID>
	) throws(NodeStoreError) -> [Value.ID] {
		guard let references = mirrorReferences(for: ids) else {
			return []
		}
		if !isValidMirrorDestination(for: references, at: destination) {
			guard let destinationID = destination.id, base[destinationID] == nil else {
				return []
			}
		}
		let inserted: [Container<Value>] = references.map {
			.mirror(id: Value.ID.random(), reference: $0)
		}
		try base.insert(inserted, at: destination)
		return inserted.map(\.id)
	}

	func canInsertMirror(
		for ids: [Value.ID],
		to destination: Destination<Value.ID>
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

	func item(with id: Value.ID) -> Resolved<Value, Value.ID>? {
		guard let container = base[id] else {
			return nil
		}
		switch container {
		case let .item(value):
			return Resolved(id: id, content: value)
		case let .mirror(_, reference):
			guard case let .item(value) = base[reference] else {
				fatalError("Link to non-item")
			}
			return Resolved(id: id, content: value, isMirror: true)
		}
	}
}

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

// MARK: - NodeStoring
extension MirrorStore: NodeStoring {

	public var identifiers: Set<Value.ID> {
		base.identifiers
	}

	// MARK: - Subscripts

	public subscript(id: Value.ID) -> Value? {
		item(with: id)
	}

	public func parent(of id: Value.ID) -> Value? {
		fatalError()
	}

	public func descendantIDs(including ids: Set<Value.ID>) -> Set<Value.ID> {
		base.descendantIDs(including: ids)
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
		withIDs ids: S,
		to destination: Destination<Value.ID>
	) throws(NodeStoreError) where S.Element == Value.ID {
		guard canMoveItems(withIDs: ids, to: destination) else {
			return
		}
		try base.moveItems(withIDs: ids, to: destination)
	}

	public func canMoveItems<S: Sequence>(
		withIDs ids: S,
		to destination: Destination<Value.ID>
	) -> Bool where S.Element == Value.ID {
		let identifiers = Array(ids)
		guard base.canMoveItems(withIDs: identifiers, to: destination) else {
			return false
		}

		guard let destinationID = destination.id else {
			return true
		}

		guard case .item = base[destinationID] else {
			return false
		}

		var ancestorIDs = Set<ID>()
		var currentID: ID? = destinationID

		while let id = currentID {
			guard ancestorIDs.insert(id).inserted else {
				return false
			}
			currentID = base.parent(of: id)?.id
		}

		let movedIDs = base.descendantIDs(including: Set(identifiers))

		return movedIDs.allSatisfy { id in
			guard case let .mirror(_, reference) = base[id] else {
				return true
			}
			return !ancestorIDs.contains(reference)
		}
	}

	public func deleteItems<S: Sequence>(withIDs ids: S) where S.Element == Value.ID {
		let identifiers = Array(ids)
		let subtreeIDs = base.descendantIDs(including: Set(identifiers))
		let originalIDs = subtreeIDs.reduce(into: Set<ID>()) { result, id in
			guard case .item = base[id] else {
				return
			}
			result.insert(id)
		}

		guard !originalIDs.isEmpty else {
			base.deleteItems(withIDs: identifiers)
			return
		}

		let externalMirrorIDs = base.identifiers.subtracting(subtreeIDs).filter { id in
			guard case let .mirror(_, reference) = base[id] else {
				return false
			}
			return originalIDs.contains(reference)
		}

		base.deleteItems(withIDs: identifiers + Array(externalMirrorIDs))
	}

	public func set<T>(
		_ keyPath: WritableKeyPath<Value, T>,
		to value: T,
		forItemsWithIDs ids: [Value.ID],
		includingDescendants: Bool
	) {
		let selectedIDs = Set(ids)
		let targetIDs = includingDescendants
			? base.descendantIDs(including: selectedIDs)
			: selectedIDs

		let originalIDs = Set(
			targetIDs.compactMap {
				item(with: $0)?.id
			}
		)

		let itemKeyPath = (\Container<Value>.itemValue).appending(path: keyPath)
		base.set(
			itemKeyPath,
			to: value,
			forItemsWithIDs: Array(originalIDs),
			includingDescendants: false
		)
	}
}

// MARK: - MirrorStoring
extension MirrorStore: MirrorStoring {

	public func insertMirror(
		for ids: [Value.ID],
		to destination: Destination<Value.ID>
	) throws(NodeStoreError) -> [Value.ID] {
		let inserted: [Container<Value>] = ids.compactMap {
			.mirror(id: Value.ID.random(), reference: $0)
		}
		try base.insert(inserted, at: destination)
		return inserted.map(\.id)
	}
}

// MARK: - Helpers
private extension MirrorStore {

	func item(with id: Value.ID) -> Value? {
		guard let container = base[id] else {
			return nil
		}
		switch container {
		case let .item(value):
			return value
		case let .mirror(_, reference):
			guard case let .item(value) = base[reference] else {
				fatalError("Link to non-item")
			}
			return value
		}
	}
}

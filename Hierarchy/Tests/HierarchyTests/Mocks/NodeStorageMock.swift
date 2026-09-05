//
//  NodeStorageMock.swift
//  HierarchyTests
//
//  Created by Anton Cherkasov on 05.09.2026.
//

@testable import Hierarchy

final class NodeStorageMock<Value: Identifiable & Equatable> where Value.ID: Hashable {

	private(set) var invocations: [Action] = []
	var stubs = Stubs()
}

// MARK: - NodeStoring
extension NodeStorageMock: NodeStoring {

	var identifiers: Set<Value.ID> {
		invocations.append(.identifiers)
		return Set(stubs.items.keys)
	}

	subscript(id: Value.ID) -> Value? {
		invocations.append(.item(id: id))
		return stubs.items[id]
	}

	func insert<S: Sequence>(_ items: S, at destination: Destination<Value.ID>) where S.Element == Value {
		invocations.append(.insert(items: Array(items), destination: destination))
	}

	func moveItems<S: Sequence>(
		withIDs ids: S,
		to destination: Destination<Value.ID>
	) where S.Element == Value.ID {
		invocations.append(.moveItems(ids: Array(ids), destination: destination))
	}

	func canMoveItems<S: Sequence>(
		withIDs ids: S,
		to destination: Destination<Value.ID>
	) -> Bool where S.Element == Value.ID {
		invocations.append(.canMoveItems(ids: Array(ids), destination: destination))
		return stubs.canMoveItems
	}

	func deleteItems<S: Sequence>(withIDs ids: S) where S.Element == Value.ID {
		invocations.append(.deleteItems(ids: Array(ids)))
	}

	func set<T>(
		_ keyPath: WritableKeyPath<Value, T>,
		to value: T,
		forItemsWithIDs ids: [Value.ID],
		includingDescendants: Bool
	) {
		invocations.append(.set(ids: ids, includingDescendants: includingDescendants))

		let targetIDs: Set<Value.ID>
		if includingDescendants {
			targetIDs = ids.reduce(into: Set<Value.ID>()) { result, id in
				result.formUnion(stubs.descendants[id] ?? [id])
			}
		} else {
			targetIDs = Set(ids)
		}

		for id in targetIDs {
			guard var item = stubs.items[id] else {
				continue
			}
			item[keyPath: keyPath] = value
			stubs.items[id] = item
		}
	}

	func parent(of id: Value.ID) -> Value? {
		invocations.append(.parent(id: id))
		guard let parentID = stubs.parents[id] else {
			return nil
		}
		return stubs.items[parentID]
	}

	func descendantIDs(including ids: Set<Value.ID>) -> Set<Value.ID> {
		invocations.append(.descendantIDs(ids: ids))
		return ids.reduce(into: Set<Value.ID>()) { result, id in
			result.formUnion(stubs.descendants[id] ?? [id])
		}
	}
}

// MARK: - Nested Data Structs
extension NodeStorageMock {

	enum Action: Equatable {
		case identifiers
		case item(id: Value.ID)
		case insert(items: [Value], destination: Destination<Value.ID>)
		case moveItems(ids: [Value.ID], destination: Destination<Value.ID>)
		case canMoveItems(ids: [Value.ID], destination: Destination<Value.ID>)
		case deleteItems(ids: [Value.ID])
		case set(ids: [Value.ID], includingDescendants: Bool)
		case parent(id: Value.ID)
		case descendantIDs(ids: Set<Value.ID>)
	}

	struct Stubs {
		var items: [Value.ID: Value] = [:]
		var parents: [Value.ID: Value.ID] = [:]
		var descendants: [Value.ID: Set<Value.ID>] = [:]
		var canMoveItems = true
	}
}

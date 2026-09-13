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

	func insertItems(
		from data: [any TreeNode<Value>],
		to destination: Destination<Value.ID>
	) throws(NodeStoreError) {
		invocations.append(.insertItems(
			items: data.map { node in
				node.value
			},
			childrenCounts: data.map { node in
				node.children.count
			},
			destination: destination
		))
		if let insertError = stubs.insertError {
			throw insertError
		}
	}

	func moveItems<S: Sequence>(
		_ ids: S,
		to destination: Destination<Value.ID>
	) throws(NodeStoreError) where S.Element == Value.ID {
		invocations.append(.moveItems(ids: Array(ids), destination: destination))
		if let moveItemsError = stubs.moveItemsError {
			throw moveItemsError
		}
	}

	func deleteItems<S: Sequence>(_ ids: S) where S.Element == Value.ID {
		invocations.append(.deleteItems(ids: Array(ids)))
	}

	func set<T>(
		_ keyPath: WritableKeyPath<Value, T>,
		to value: T,
		for ids: [Value.ID],
		includingDescendants: Bool
	) {
		invocations.append(.set(ids: ids, includingDescendants: includingDescendants))

		let targetIDs: Set<Value.ID>
		if includingDescendants {
			targetIDs = descendantIDs(including: Set(ids))
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

}

// MARK: - NodeReading
extension NodeStorageMock: NodeReading {

	var identifiers: Set<Value.ID> {
		invocations.append(.identifiers)
		return Set(stubs.items.keys)
	}

	func parent(of id: Value.ID) -> Value.ID? {
		invocations.append(.parent(id: id))
		return stubs.parents[id]
	}

	func children(of parent: Value.ID?) -> [Value.ID] {
		invocations.append(.children(parent: parent))
		guard let parent else {
			return stubs.rootIDs
		}
		return stubs.children[parent] ?? []
	}

	subscript(id: Value.ID) -> Value? {
		invocations.append(.item(id: id))
		return stubs.items[id]
	}
}

// MARK: - Nested data structs
extension NodeStorageMock {

	enum Action: Equatable {
		case identifiers
		case item(id: Value.ID)
		case insertItems(
			items: [Value],
			childrenCounts: [Int],
			destination: Destination<Value.ID>
		)
		case moveItems(ids: [Value.ID], destination: Destination<Value.ID>)
		case deleteItems(ids: [Value.ID])
		case set(ids: [Value.ID], includingDescendants: Bool)
		case parent(id: Value.ID)
		case children(parent: Value.ID?)
	}

	struct Stubs {
		var items: [Value.ID: Value] = [:]
		var parents: [Value.ID: Value.ID] = [:]
		var rootIDs: [Value.ID] = []
		var children: [Value.ID: [Value.ID]] = [:]
		var insertError: NodeStoreError?
		var moveItemsError: NodeStoreError?
	}
}

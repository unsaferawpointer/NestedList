//
//  NodeStoring.swift
//  Hierarchy
//
//  Created by Anton Cherkasov on 03.09.2026.
//

import Foundation

public protocol NodeStoring<Value>: NodeReading where Value: Identifiable {

	func insertItems(
		from data: [any TreeNode<Value>],
		to destination: Destination<ID>
	) throws(NodeStoreError)

	func moveItems<S: Sequence>(
		_ ids: S,
		to destination: Destination<ID>
	) throws(NodeStoreError) where S.Element == ID

	func canMoveItems<S: Sequence>(_ ids: S, to destination: Destination<ID>) -> Bool where S.Element == ID

	func deleteItems<S: Sequence>(_ ids: S) where S.Element == ID

	func set<T>(
		_ keyPath: WritableKeyPath<Value, T>,
		to value: T,
		for ids: [ID],
		includingDescendants: Bool
	)
}

// MARK: - Insertion
public extension NodeStoring {

	/// Inserts the specified values as leaf nodes at the destination.
	func insert<S: Sequence>(
		_ items: S,
		at destination: Destination<ID>
	) throws(NodeStoreError) where S.Element == Value {
		let nodes: [any TreeNode<Value>] = items.map { value in
			Node(value: value)
		}
		try insertItems(from: nodes, to: destination)
	}
}

// MARK: - Moving
public extension NodeStoring {

	/// Returns whether the specified nodes can be moved to the destination without creating a cycle.
	func canMoveItems<S: Sequence>(_ ids: S, to destination: Destination<ID>) -> Bool where S.Element == ID {
		guard let target = destination.id, self[target] != nil else {
			return true
		}

		let moved = Set(ids)
		var current: ID? = target
		while let id = current {
			guard !moved.contains(id) else {
				return false
			}
			current = parent(of: id)
		}
		return true
	}

	/// Moves the specified nodes to the end of their current parent containers.
	func moveToEnd(_ ids: [ID]) throws(NodeStoreError) {
		let grouped = Dictionary(grouping: ids.filter { id in
			self[id] != nil
		}) { id in
			parent(of: id)
		}

		for (parent, ids) in grouped {
			try moveItems(ids, to: Destination(target: parent))
		}
	}

	/// Returns whether the specified node can be moved one position forward among its siblings.
	func validateMovingForward(_ id: ID) -> Bool {
		guard let location = location(of: id) else {
			return false
		}
		return location.index + 1 < location.count
	}

	/// Returns whether the specified node can be moved one position backward among its siblings.
	func validateMovingBackward(_ id: ID) -> Bool {
		guard let location = location(of: id) else {
			return false
		}
		return location.index > 0
	}

	/// Moves the specified node one position forward among its siblings.
	func moveForward(_ id: ID) throws(NodeStoreError) {
		guard let location = location(of: id), location.index + 1 < location.count else {
			return
		}
		try moveItems([id], to: Destination(target: location.parent, index: location.index + 2))
	}

	/// Moves the specified node one position backward among its siblings.
	func moveBackward(_ id: ID) throws(NodeStoreError) {
		guard let location = location(of: id), location.index > 0 else {
			return
		}
		try moveItems([id], to: Destination(target: location.parent, index: location.index - 1))
	}
}

// MARK: - Helpers
private extension NodeStoring {

	func location(of id: ID) -> (parent: ID?, index: Int, count: Int)? {
		let parent = parent(of: id)
		let siblings = children(of: parent)
		guard let index = siblings.firstIndex(of: id) else {
			return nil
		}
		return (parent, index, siblings.count)
	}
}

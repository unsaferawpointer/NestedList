//
//  NodeReading.swift
//  Hierarchy
//
//  Created by Anton Cherkasov on 06.09.2026.
//

import Foundation

/// Provides read-only access to values and relationships in hierarchical node storage.
///
/// Conforming types expose node lookup by identifier without revealing their underlying
/// tree representation.
public protocol NodeReading<Value> {

	/// The value stored in each node.
	associatedtype Value: Identifiable

	/// The identifier used to address nodes in the hierarchy.
	typealias ID = Value.ID

	/// The identifiers of all nodes currently stored in the hierarchy.
	var identifiers: Set<ID> { get }

	/// Returns the parent identifier for the node with the specified identifier.
	///
	/// Returns `nil` when the node is not found or the node is a root node.
	///
	/// - Parameter id: The identifier of the node whose parent should be returned.
	/// - Returns: The parent node's identifier, or `nil` when no parent is available.
	func parent(of id: ID) -> ID?

	/// Returns the ordered identifiers of the direct children of the specified parent.
	///
	/// Pass `nil` to retrieve the root identifiers. Returns an empty array when the parent is not found
	/// or has no children.
	///
	/// - Parameter parent: The parent identifier, or `nil` for the root container.
	/// - Returns: The direct child identifiers in storage order.
	func children(of parent: ID?) -> [ID]

	// MARK: - Subscripts

	/// Returns the value of the node with the specified identifier.
	///
	/// - Parameter id: The identifier of the node to retrieve.
	/// - Returns: The stored value, or `nil` when the node is not found.
	subscript(id: Value.ID) -> Value? { get }
}

// MARK: - Tree nodes
public extension NodeReading {

	/// Reconstructs the stored hierarchy using the specified tree node type.
	///
	/// Identifiers without a corresponding stored value are skipped.
	///
	/// - Parameter type: The tree node type used to represent the hierarchy.
	/// - Returns: The root nodes in storage order, including their descendants.
	func nodes<T: TreeNode>(type: T.Type) -> [T] where T.Value == Value {
		return children(of: nil).compactMap { id in
			node(with: id, type: type)
		}
	}

	/// Reconstructs the subtree rooted at the specified identifier.
	///
	/// Identifiers without a corresponding stored value are skipped.
	///
	/// - Parameters:
	///   - id: The identifier of the subtree root.
	///   - type: The tree node type used to represent the subtree.
	/// - Returns: The reconstructed subtree, or `nil` when the root value is not found.
	func node<T: TreeNode>(with id: ID, type: T.Type) -> T? where T.Value == Value {
		guard let value = self[id] else {
			return nil
		}
		return T(
			value: value,
			children: children(of: id).compactMap { id in
				node(with: id, type: type)
			}
		)
	}
}

// MARK: - Snapshot Support
public extension NodeReading {

	/// Returns a snapshot of the current hierarchy.
	func snapshot() -> Snapshot<Value> {
		return Snapshot(nodes(type: Node<Value>.self))
	}
}

// MARK: - Copying
public extension NodeReading {

	/// Returns copied subtrees for the requested identifiers without nested duplicates.
	///
	/// If both a parent and one of its descendants are requested, the descendant is returned as
	/// a separate copied subtree and removed from the parent's copied subtree.
	func copiedDisjointSubtrees(with ids: [ID]) -> [any TreeNode<Value>] {
		let identifiers = Set(ids)
		let copied = ids.compactMap { id in
			node(with: id, type: Node<Value>.self)
		}
		copied.forEach { node in
			node.deleteDescendants(with: identifiers)
		}
		return copied
	}
}

// MARK: - Matching
public extension NodeReading {

	/// Returns `true` when every leaf node in the specified subtree has a matching value at the given key path.
	///
	/// - Parameters:
	///   - id: The identifier of the subtree root.
	///   - keyPath: The value property to compare.
	///   - value: The expected value.
	/// - Returns: `false` when the root node is not found or at least one leaf does not match.
	func allMatch<T: Equatable>(id: ID, keyPath: KeyPath<Value, T>, equalsTo value: T) -> Bool {
		guard self[id] != nil else {
			return false
		}

		var pending = [id]
		while let id = pending.popLast() {
			let childIDs = children(of: id)
			guard childIDs.isEmpty else {
				pending.append(contentsOf: childIDs)
				continue
			}
			guard self[id]?[keyPath: keyPath] == value else {
				return false
			}
		}
		return true
	}
}

// MARK: - Enumeration
public extension NodeReading {

	/// Visits every stored value in depth-first storage order.
	///
	/// Each identifier is visited at most once. Identifiers without a corresponding stored value are skipped.
	///
	/// - Parameter block: A closure called for each value in the hierarchy.
	func enumerate(_ block: (Value) -> Void) {
		var visited = Set<ID>()
		var pending = Array(children(of: nil).reversed())

		while let id = pending.popLast() {
			guard visited.insert(id).inserted, let value = self[id] else {
				continue
			}
			block(value)
			pending.append(contentsOf: children(of: id).reversed())
		}
	}
}

// MARK: - Descendants
public extension NodeReading {

	/// Returns the identifiers of the specified nodes and all of their descendants.
	///
	/// Identifiers that do not correspond to stored nodes are omitted from the result.
	///
	/// - Parameter ids: The identifiers of the subtree roots to traverse.
	/// - Returns: The identifiers of the existing subtree roots and their descendants.
	func descendantIDs(including ids: Set<ID>) -> Set<ID> {
		var result = Set<ID>()
		var pending = Array(ids)

		while let id = pending.popLast() {
			guard self[id] != nil, result.insert(id).inserted else {
				continue
			}
			pending.append(contentsOf: children(of: id))
		}

		return result
	}
}

// MARK: - Physical ancestry
public extension NodeReading {

	/// Returns the identifiers in the physical ancestor chain of a node, including the node itself.
	///
	/// Mirror references are not traversed. Returns `nil` when the physical parent chain contains a cycle.
	func ancestorIDs(including id: ID) -> Set<ID>? {
		var result = Set<ID>()
		var current: ID? = id

		while let id = current {
			guard result.insert(id).inserted else {
				return nil
			}
			current = parent(of: id)
		}
		return result
	}
}

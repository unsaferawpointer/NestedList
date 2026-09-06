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

	/// Returns the identifiers of the specified nodes and all of their descendants.
	///
	/// Identifiers that do not correspond to stored nodes are omitted from the result.
	///
	/// - Parameter ids: The identifiers of the subtree roots to traverse.
	/// - Returns: The identifiers of the existing subtree roots and their descendants.
	func descendantIDs(including ids: Set<ID>) -> Set<ID>

	// MARK: - Subscripts

	/// Returns the value of the node with the specified identifier.
	///
	/// - Parameter id: The identifier of the node to retrieve.
	/// - Returns: The stored value, or `nil` when the node is not found.
	subscript(id: Value.ID) -> Value? { get }
}

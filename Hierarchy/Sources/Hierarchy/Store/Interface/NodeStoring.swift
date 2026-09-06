//
//  NodeStoring.swift
//  Hierarchy
//
//  Created by Anton Cherkasov on 03.09.2026.
//

import Foundation

public protocol NodeStoring<Value> {

	associatedtype Value: Identifiable

	typealias ID = Value.ID

	func insert<S: Sequence>(
		_ items: S,
		at destination: Destination<ID>
	) throws(NodeStoreError) where S.Element == Value

	func moveItems<S: Sequence>(
		withIDs ids: S,
		to destination: Destination<ID>
	) throws(NodeStoreError) where S.Element == ID

	func canMoveItems<S: Sequence>(withIDs ids: S, to destination: Destination<ID>) -> Bool where S.Element == ID

	func deleteItems<S: Sequence>(withIDs ids: S) where S.Element == ID

	func set<T>(
		_ keyPath: WritableKeyPath<Value, T>,
		to value: T,
		forItemsWithIDs ids: [ID],
		includingDescendants: Bool
	)

	var identifiers: Set<ID> { get }

	/// Returns the parent identifier for the node with the specified identifier.
	///
	/// Returns `nil` when the node is not found or the node is a root node.
	///
	/// - Parameter id: The identifier of the node whose parent should be returned.
	/// - Returns: The parent node's identifier, or `nil` when no parent is available.
	func parent(of id: ID) -> ID?

	func descendantIDs(including ids: Set<ID>) -> Set<ID>

	// MARK: - Subscripts

	subscript(id: Value.ID) -> Value? { get }
}

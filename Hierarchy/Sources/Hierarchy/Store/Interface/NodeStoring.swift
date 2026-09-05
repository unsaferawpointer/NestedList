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

	func insert<S: Sequence>(_ items: S, at destination: Destination<ID>) where S.Element == Value

	func moveItems<S: Sequence>(withIDs ids: S, to destination: Destination<ID>) where S.Element == ID

	func canMoveItems<S: Sequence>(withIDs ids: S, to destination: Destination<ID>) -> Bool where S.Element == ID

	func deleteItems<S: Sequence>(withIDs ids: S) where S.Element == ID

	func set<T>(
		_ keyPath: WritableKeyPath<Value, T>,
		to value: T,
		forItemsWithIDs ids: [ID],
		includingDescendants: Bool
	)

	var identifiers: Set<ID> { get }

	func parent(of id: ID) -> Value?

	func descendantIDs(including ids: Set<ID>) -> Set<ID>

	// MARK: - Subscripts

	subscript(id: Value.ID) -> Value? { get }
}

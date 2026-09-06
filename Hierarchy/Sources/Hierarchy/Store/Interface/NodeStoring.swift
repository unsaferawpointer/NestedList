//
//  NodeStoring.swift
//  Hierarchy
//
//  Created by Anton Cherkasov on 03.09.2026.
//

import Foundation

public protocol NodeStoring<Value>: NodeReading where Value: Identifiable {

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
}

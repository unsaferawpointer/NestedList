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

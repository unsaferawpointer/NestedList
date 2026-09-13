//
//  MirrorStoring.swift
//  Hierarchy
//
//  Created by Anton Cherkasov on 03.09.2026.
//

public protocol MirrorStoring<Content, Identifier>: NodeReading where Value == Resolved<Content, Identifier> {

	associatedtype Content
	associatedtype Identifier: Hashable

	func insert<S: Sequence>(
		_ items: S,
		at destination: Destination<Identifier>
	) throws(NodeStoreError) where S.Element == Resolved<Content, Identifier>

	func moveItems<S: Sequence>(
		_ ids: S,
		to destination: Destination<Identifier>
	) throws(NodeStoreError) where S.Element == Identifier

	func canMoveItems<S: Sequence>(
		_ ids: S,
		to destination: Destination<Identifier>
	) -> Bool where S.Element == Identifier

	func deleteItems<S: Sequence>(_ ids: S) where S.Element == Identifier

	func set<T>(
		_ keyPath: WritableKeyPath<Content, T>,
		to value: T,
		for ids: [Identifier],
		includingDescendants: Bool
	)

	func insertMirror(
		for ids: [Identifier],
		to destination: Destination<Identifier>
	) throws(NodeStoreError) -> [Identifier]

	func canInsertMirror(
		for ids: [Identifier],
		to destination: Destination<Identifier>
	) -> Bool
}

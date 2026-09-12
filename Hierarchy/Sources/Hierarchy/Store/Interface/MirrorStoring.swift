//
//  MirrorStoring.swift
//  Hierarchy
//
//  Created by Anton Cherkasov on 03.09.2026.
//

public protocol MirrorStoring<Content>: NodeReading where Value == Resolved<Content, Content.ID> {

	associatedtype Content: Identifiable

	func insert<S: Sequence>(
		_ items: S,
		at destination: Destination<Content.ID>
	) throws(NodeStoreError) where S.Element == Content

	func moveItems<S: Sequence>(
		_ ids: S,
		to destination: Destination<Content.ID>
	) throws(NodeStoreError) where S.Element == Content.ID

	func canMoveItems<S: Sequence>(
		_ ids: S,
		to destination: Destination<Content.ID>
	) -> Bool where S.Element == Content.ID

	func deleteItems<S: Sequence>(_ ids: S) where S.Element == Content.ID

	func set<T>(
		_ keyPath: WritableKeyPath<Content, T>,
		to value: T,
		for ids: [Content.ID],
		includingDescendants: Bool
	)

	func insertMirror(
		for ids: [Content.ID],
		to destination: Destination<Content.ID>
	) throws(NodeStoreError) -> [Content.ID]

	func canInsertMirror(
		for ids: [Content.ID],
		to destination: Destination<Content.ID>
	) -> Bool
}

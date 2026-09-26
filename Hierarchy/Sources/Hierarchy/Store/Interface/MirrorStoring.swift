//
//  MirrorStoring.swift
//  Hierarchy
//
//  Created by Anton Cherkasov on 03.09.2026.
//

public protocol MirrorStoring<Content, ID> {

	associatedtype Content
	associatedtype ID: RandomizableIdentifier

	func insert<T: TreeNode>(
		nodes: [T],
		to destination: Destination<ID>
	) throws(MirrorStoreError) where T.Value == Container<Content, ID>

	func deleteItems<S: Sequence>(_ ids: S) where S.Element == ID

	func moveItems<S>(
		_ ids: S,
		to destination: Destination<ID>
	) throws(MirrorStoreError) where S : Sequence, S.Element == ID

	func validateMove<S: Sequence>(
		_ ids: S,
		to destination: Destination<ID>
	) -> Bool where S.Element == ID
}

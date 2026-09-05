//
//  MirrorStoring.swift
//  Hierarchy
//
//  Created by Anton Cherkasov on 03.09.2026.
//

public protocol MirrorStoring<Value>: NodeStoring {

	associatedtype Value

	func insertMirror(
		for ids: [Value.ID],
		to destination: Destination<Value.ID>
	) throws(NodeStoreError) -> [Value.ID]
}

//
//  MirrorReading.swift
//  Hierarchy
//
//  Created by Anton Cherkasov on 13.09.2026.
//

import Foundation

public protocol MirrorReading<Content, ID> {

	associatedtype Content
	associatedtype ID: Hashable

	var identifiers: Set<ID> { get }

	func parent(of id: ID) -> ID?

	func children(of parent: ID?) -> [ID]

	func snapshot() -> Snapshot<Resolved<Content, ID>>

	subscript(id: ID) -> Resolved<Content, ID>? { get }
}

// MARK: - Snapshot Support
public extension MirrorReading {

	func snapshot() -> Snapshot<Resolved<Content, ID>> {
		func node(with id: ID) -> Node<Resolved<Content, ID>>? {
			guard let value = self[id] else {
				return nil
			}
			return Node(
				value: value,
				children: children(of: id).compactMap { node(with: $0) }
			)
		}

		let nodes = children(of: nil)
			.compactMap {
				node(with: $0)
			}
		return Snapshot(nodes)
	}
}

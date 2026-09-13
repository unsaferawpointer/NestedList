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

	subscript(id: ID) -> Resolved<Content, ID>? { get }
}

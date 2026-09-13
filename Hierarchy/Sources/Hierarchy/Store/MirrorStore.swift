//
//  MirrorStore.swift
//  Hierarchy
//
//  Created by Anton Cherkasov on 13.09.2026.
//

import Foundation

final class MirrorStore<Content, ID: RandomizableIdentifier> {

	private let base: any NodeReading<Container<Content, ID>>

	// MARK: - Initialization

	init(base: any NodeReading<Container<Content, ID>>) {
		self.base = base
	}

	public convenience init() {
		self.init(base: NodeStore())
	}
}

// MARK: - MirrorReading
extension MirrorStore: MirrorReading {

	var identifiers: Set<ID> {
		base.identifiers
	}

	func parent(of id: ID) -> ID? {
		base.parent(of: id)
	}

	func children(of parent: ID?) -> [ID] {
		base.children(of: parent)
	}

	subscript(id: ID) -> Resolved<Content, ID>? {
		item(with: id)
	}
}

// MARK: - Helpers
private extension MirrorStore {

	func item(with id: ID) -> Resolved<Content, ID>? {
		guard let container = base[id] else {
			return nil
		}
		switch container {
		case let .item(_, content):
			return Resolved(id: id, content: content)
		case let .mirror(_, reference):
			guard case let .item(_, content) = base[reference] else {
				assertionFailure("Link to non-item")
				return nil
			}
			return Resolved(id: id, content: content, isMirror: true)
		}
	}
}

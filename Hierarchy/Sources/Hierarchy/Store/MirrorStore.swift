//
//  MirrorStore.swift
//  Hierarchy
//
//  Created by Anton Cherkasov on 13.09.2026.
//

import Foundation

final class MirrorStore<Content, ID: RandomizableIdentifier> {

	// MARK: - Internal State

	private var cache = Cache()

	private var nodes: [Node<Container<Content, ID>>] = []

	// MARK: - Initialization

	public init() { }
}

// MARK: - MirrorReading
extension MirrorStore: MirrorReading {

	var identifiers: Set<ID> {
		cache.identifiers
	}

	func parent(of id: ID) -> ID? {
		return cache[id]?.parent?.id
	}

	func children(of parent: ID?) -> [ID] {
		guard let parent else {
			return nodes.map(\.id)
		}
		return cache[parent]?.children.map(\.id) ?? []
	}

	subscript(id: ID) -> Resolved<Content, ID>? {
		item(with: id)
	}
}

// MARK: - Helpers
private extension MirrorStore {

	func item(with id: ID) -> Resolved<Content, ID>? {
		guard let container = cache[id]?.value else {
			return nil
		}
		switch container {
		case let .item(_, content):
			return Resolved(id: id, content: content)
		case let .mirror(_, reference):
			guard case let .item(_, content) = cache[reference]?.value else {
				assertionFailure("Link to non-item")
				return nil
			}
			return Resolved(id: id, content: content, isMirror: true)
		}
	}
}

// MARK: - Nested Data Structs
extension MirrorStore {

	struct Cache {
		var storage: [ID: Node<Container<Content, ID>>] = [:]
		var identifiers: Set<ID> = .init()
	}
}

// MARK: - Subscript
extension MirrorStore.Cache {

	subscript(id: ID) -> Node<Container<Content, ID>>? {
		get {
			storage[id]
		}
	}
}

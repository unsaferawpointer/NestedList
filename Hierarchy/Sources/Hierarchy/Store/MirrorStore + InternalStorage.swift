//
//  MirrorStore + InternalStorage.swift
//  Hierarchy
//
//  Created by Anton Cherkasov on 27.09.2026.
//

extension MirrorStore {

	struct InternalStorage {

		private var cache = Cache()

		var nodes: [Node<Container<Content, ID>>] = []
	}
}

extension MirrorStore.InternalStorage {

	mutating func insert(_ node: Node<Container<Content, ID>>) {
		cache.storage[node.id] = node
		cache.identifiers.insert(node.id)
	}

	mutating func remove(_ node: Node<Container<Content, ID>>) {
		cache.storage[node.id] = nil
		cache.identifiers.remove(node.id)
	}

	mutating func resetCache() {
		cache = .init()
	}

	mutating func updateCache(inserted nodes: [Node<Container<Content, ID>>]) {
		for node in nodes {
			node.traverse { node in
				insert(node)
			}
		}
	}

	mutating func updateCache(removed nodes: [Node<Container<Content, ID>>]) {
		for node in nodes {
			node.traverse { node in
				remove(node)
			}
		}
	}

	var identifiers: Set<ID> {
		cache.identifiers
	}

	subscript(id: ID) -> Node<Container<Content, ID>>? {
		cache.storage[id]
	}
}

// MARK: - Nested Data Structs
extension MirrorStore.InternalStorage {

	private struct Cache {
		var storage: [ID: Node<Container<Content, ID>>] = [:]
		var identifiers: Set<ID> = .init()
	}
}

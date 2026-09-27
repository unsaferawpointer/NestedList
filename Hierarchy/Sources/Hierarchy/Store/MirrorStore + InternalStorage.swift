//
//  MirrorStore + InternalStorage.swift
//  Hierarchy
//
//  Created by Anton Cherkasov on 27.09.2026.
//

extension MirrorStore {

	struct InternalStorage {

		var cache = Cache()

		var nodes: [Node<Container<Content, ID>>] = []
	}
}

// MARK: - Nested Data Structs
extension MirrorStore.InternalStorage {

	struct Cache {
		private var storage: [ID: Node<Container<Content, ID>>] = [:]
		private(set) var identifiers: Set<ID> = .init()
	}
}

extension MirrorStore.InternalStorage.Cache {

	mutating func insert(_ node: Node<Container<Content, ID>>) {
		storage[node.id] = node
		identifiers.insert(node.id)
	}

	mutating func remove(_ node: Node<Container<Content, ID>>) {
		storage[node.id] = nil
		identifiers.remove(node.id)
	}
}

// MARK: - Subscript
extension MirrorStore.InternalStorage.Cache {

	subscript(id: ID) -> Node<Container<Content, ID>>? {
		get {
			storage[id]
		}
	}
}

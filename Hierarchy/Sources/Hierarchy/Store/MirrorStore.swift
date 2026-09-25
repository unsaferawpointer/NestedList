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

	convenience init<T: TreeNode>(nodes: [T]) throws(MirrorStoreError) where T.Value == Container<Content, ID> {
		self.init()
		try insert(nodes: nodes, to: .toRoot)
	}
}

// MARK: - Insertion
extension MirrorStore {

	func insert<T: TreeNode>(
		nodes: [T],
		to destination: Destination<ID>
	) throws(MirrorStoreError) where T.Value == Container<Content, ID> {
		let newNodes = nodes.map {
			$0.map(type: Node<Container<Content, ID>>.self)
		}

		try validateUniqueIdentifiers(in: newNodes)
		try validateDestination(destination)
		prepareIdentifiers(for: newNodes)

		insert(newNodes, to: destination)
		updateCache(inserted: newNodes)

		do {
			try validateStore()
		} catch {
			remove(newNodes, from: destination)
			updateCache(removed: newNodes)
			throw error
		}
	}

}

// MARK: - Insertion Helpers
private extension MirrorStore {

	func insert(
		_ nodes: [Node<Container<Content, ID>>],
		to destination: Destination<ID>
	) {
		switch destination {
		case .toRoot:
			self.nodes.append(contentsOf: nodes)
		case let .inRoot(atIndex: index):
			self.nodes.insert(contentsOf: nodes, at: index)
		case let .onItem(with: id):
			cache[id]?.appendItems(with: nodes)
		case let .inItem(with: id, atIndex: index):
			cache[id]?.insertItems(with: nodes, to: index)
		}
	}

	func prepareIdentifiers(for nodes: [Node<Container<Content, ID>>]) {
		var occupied = cache.identifiers
		var replacements: [ID: ID] = [:]

		for root in nodes {
			root.traverse { node in
				let originalID = node.id
				guard occupied.contains(originalID) else {
					occupied.insert(originalID)
					return
				}

				var replacement = ID.random()
				while occupied.contains(replacement) {
					replacement = ID.random()
				}
				node.value.id = replacement
				replacements[originalID] = replacement
				occupied.insert(replacement)
			}
		}

		guard !replacements.isEmpty else {
			return
		}

		for root in nodes {
			root.traverse { node in
				guard case let .mirror(id, reference) = node.value,
					  let replacement = replacements[reference] else {
					return
				}
				node.value = .mirror(id: id, reference: replacement)
			}
		}
	}

	func remove(
		_ nodes: [Node<Container<Content, ID>>],
		from destination: Destination<ID>
	) {
		let identifiers = Set(nodes.map(\.id))
		switch destination {
		case .toRoot, .inRoot:
			self.nodes.removeAll { identifiers.contains($0.id) }
		case let .onItem(with: id), let .inItem(with: id, atIndex: _):
			cache[id]?.children.removeAll { identifiers.contains($0.id) }
		}
	}
}

// MARK: - Validation
private extension MirrorStore {

	func validateStore() throws(MirrorStoreError) {
		try validateUniqueIdentifiers(in: nodes)
		try validateReferences(in: nodes)
		try validateReferenceCycles(in: nodes)
		try validateMirrorChildren(in: nodes)
	}

	func validateDestination(_ destination: Destination<ID>) throws(MirrorStoreError) {
		switch destination {
		case .toRoot:
			return
		case let .inRoot(atIndex: index):
			guard (0...nodes.count).contains(index) else {
				throw MirrorStoreError.invalidDestinationIndex
			}
		case let .onItem(with: id):
			guard cache[id] != nil else {
				throw MirrorStoreError.missingDestination
			}
		case let .inItem(with: id, atIndex: index):
			guard let target = cache[id] else {
				throw MirrorStoreError.missingDestination
			}
			guard (0...target.children.count).contains(index) else {
				throw MirrorStoreError.invalidDestinationIndex
			}
		}
	}

	func validateUniqueIdentifiers(
		in nodes: [Node<Container<Content, ID>>]
	) throws(MirrorStoreError) {
		var identifiers = Set<ID>()
		for node in nodes {
			try node.traverse(
				enter: { (node: Node<Container<Content, ID>>) throws(MirrorStoreError) in
					guard identifiers.insert(node.id).inserted else {
						throw MirrorStoreError.duplicateIdentifier
					}
				}
			)
		}
	}

	func validateReferences(
		in nodes: [Node<Container<Content, ID>>]
	) throws(MirrorStoreError) {
		for node in nodes {
			try node.traverse(
				enter: { (node: Node<Container<Content, ID>>) throws(MirrorStoreError) in
					guard case let .mirror(_, reference) = node.value else {
						return
					}
					guard let target = cache[reference] else {
						throw MirrorStoreError.missingReference
					}
					guard case .item = target.value else {
						throw MirrorStoreError.referenceIsMirror
					}
				}
			)
		}
	}

	func validateReferenceCycles(
		in nodes: [Node<Container<Content, ID>>]
	) throws(MirrorStoreError) {
		var dependencies: [ID: Set<ID>] = [:]

		for node in nodes {
			var itemAncestors: [ID] = []
			node.traverse(
				enter: { node in
					switch node.value {
					case let .item(id, _):
						itemAncestors.append(id)
					case let .mirror(_, reference):
						for ancestor in itemAncestors {
							dependencies[ancestor, default: []].insert(reference)
						}
					}
				},
				leave: { node in
					if case .item = node.value {
						itemAncestors.removeLast()
					}
				}
			)
		}

		var visited = Set<ID>()
		var visiting = Set<ID>()

		for start in dependencies.keys where !visited.contains(start) {
			var pending: [(id: ID, leaving: Bool)] = [(start, false)]

			while let visit = pending.popLast() {
				if visit.leaving {
					visiting.remove(visit.id)
					visited.insert(visit.id)
					continue
				}

				guard !visited.contains(visit.id) else {
					continue
				}
				guard visiting.insert(visit.id).inserted else {
					throw MirrorStoreError.referenceCycle
				}

				pending.append((visit.id, true))
				for dependency in dependencies[visit.id, default: []] {
					guard !visiting.contains(dependency) else {
						throw MirrorStoreError.referenceCycle
					}
					if !visited.contains(dependency) {
						pending.append((dependency, false))
					}
				}
			}
		}
	}

	func validateMirrorChildren(
		in nodes: [Node<Container<Content, ID>>]
	) throws(MirrorStoreError) {
		for node in nodes {
			try node.traverse(
				enter: { (node: Node<Container<Content, ID>>) throws(MirrorStoreError) in
					if case .mirror = node.value, !node.children.isEmpty {
						throw MirrorStoreError.mirrorHasChildren
					}
				}
			)
		}
	}

	func updateCache(inserted nodes: [Node<Container<Content, ID>>]) {
		for node in nodes {
			node.traverse { node in
				cache.insert(node)
			}
		}
	}

	func updateCache(removed nodes: [Node<Container<Content, ID>>]) {
		for node in nodes {
			node.traverse { node in
				cache.remove(node)
			}
		}
	}
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
		private var storage: [ID: Node<Container<Content, ID>>] = [:]
		private(set) var identifiers: Set<ID> = .init()
	}
}

extension MirrorStore.Cache {

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
extension MirrorStore.Cache {

	subscript(id: ID) -> Node<Container<Content, ID>>? {
		get {
			storage[id]
		}
	}
}

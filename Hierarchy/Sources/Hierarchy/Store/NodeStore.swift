//
//  NodeStore.swift
//  Hierarchy
//
//  Created by Anton Cherkasov on 17.11.2024.
//

import Foundation

public final class NodeStore<Value: MutableIdentifiable> where Value.ID: RandomizableIdentifier {

	public typealias ID = Value.ID

	private var nodes: [Node<Value>] = []

	// MARK: - Cache

	private(set) var cache: [ID: Node<Value>] = [:]

	// MARK: - Initialization

	public init<T: TreeNode>(hierarchy: [T]) where T.Value == Value {
		self.nodes = hierarchy.map {
			$0.map(type: Node<Value>.self)
		}
		updateCache(inserted: nodes)
	}

	public init() { }
}

// MARK: - Equatable
extension NodeStore: Equatable where Value: Equatable {

	public static func == (lhs: NodeStore<Value>, rhs: NodeStore<Value>) -> Bool {
		return lhs.nodes == rhs.nodes
	}
}

// MARK: - NodeStoring
extension NodeStore: NodeStoring {

	public func insertItems(
		from data: [any TreeNode<Value>],
		to destination: Destination<Value.ID>
	) throws(NodeStoreError) {
		let newNodes = data.map { node in
			node.map(type: Node<Value>.self)
		}
		try insertNodes(newNodes, to: destination)
	}
	
	public func moveItems<S>(
		_ ids: S,
		to destination: Destination<ID>
	) throws(NodeStoreError) where S : Sequence, S.Element == Value.ID {
		let moved = ids.compactMap {
			cache[$0]
		}

		switch destination {
		case .toRoot:
			move(moved, to: nil)
		case let .inRoot(index):
			moveToRoot(moved, at: index)
		case let .onItem(id):
			guard let target = cache[id] else {
				throw .missingNode
			}
			move(moved, to: target)
		case let .inItem(id, index):
			guard let target = cache[id] else {
				throw .missingNode
			}
			move(moved, toOther: target, at: index)
		}
	}
	
	public func deleteItems<S>(_ ids: S) where S : Sequence, S.Element == Value.ID {
		ids.forEach { deleteItem($0) }
	}
	
	public func set<T>(
		_ keyPath: WritableKeyPath<Value, T>,
		to value: T,
		for ids: [ID],
		includingDescendants: Bool
	) {
		for id in ids {
			guard let node = cache[id] else {
				continue
			}
			guard includingDescendants else {
				node.value[keyPath: keyPath] = value
				continue
			}
			enumerate([node]) { node in
				node.value[keyPath: keyPath] = value
			}
		}
	}
}

// MARK: - NodeReading
extension NodeStore: NodeReading {

	public var identifiers: Set<ID> {
		return Set(cache.keys)
	}

	public func parent(of id: ID) -> ID? {
		return cache[id]?.parent?.id
	}

	public func children(of parent: ID?) -> [ID] {
		guard let parent else {
			return nodes.map(\.id)
		}
		return cache[parent]?.children.map(\.id) ?? []
	}

	public subscript(_ id: ID) -> Value? {
		get {
			cache[id]?.value
		}
	}
}

// MARK: - Helpers
private extension NodeStore {

	func updateCache(inserted nodes: [Node<Value>]) {
		enumerate(nodes) { node in
			while cache[node.id] != nil {
				node.value.id = Value.ID.random()
			}
			cache[node.id] = node
		}
	}

	func updateCache(removed nodes: [Node<Value>]) {
		enumerate(nodes) { node in
			cache[node.id] = nil
		}
	}

	func enumerate(_ nodes: [Node<Value>], _ block: (Node<Value>) -> Void) {
		var stack = Array(nodes.reversed())
		while let node = stack.popLast() {
			block(node)
			stack.append(contentsOf: node.children.reversed())
		}
	}
}

// MARK: - Insertion
extension NodeStore {

	func insertNodes(_ newNodes: [Node<Value>], to destination: Destination<Value.ID>) throws(NodeStoreError) {
		switch destination {
		case .toRoot:
			nodes.append(contentsOf: newNodes)
		case let .inRoot(index):
			nodes.insert(contentsOf: newNodes, at: index)
		case let .onItem(id):
			guard let item = cache[id] else {
				throw .missingNode
			}
			item.appendItems(with: newNodes)
		case let .inItem(id, index):
			guard let item = cache[id] else {
				throw .missingNode
			}
			item.insertItems(with: newNodes, to: index)
		}
		updateCache(inserted: newNodes)
	}

}

// MARK: - Deletion
private extension NodeStore {

	func deleteItem(_ id: ID) {
		guard let item = cache[id] else {
			return
		}

		updateCache(removed: [item])

		guard let parent = item.parent else {
			if let index = nodes.firstIndex(where: \.id, equalsTo: id) {
				nodes.remove(at: index)
			}
			return
		}
		parent.deleteChild(id)
	}
}

// MARK: - Support moving
private extension NodeStore {

	func moveToRoot(_ moved: [Node<Value>], at index: Int) {

		let grouped = Dictionary<ID?, [Node<Value>]>(grouping: moved) { item in
			return item.parent?.id
		}

		var offset = 0

		for (containerID, items) in grouped {

			let cache = Set(items.map(\.id))

			guard let containerID, let container = self.cache[containerID] else {

				offset = self.offset(
					moved: cache,
					in: nodes,
					to: index
				)

				nodes.removeAll { item in
					cache.contains(item.id)
				}
				continue
			}

			container.children.removeAll { item in
				cache.contains(item.id)
			}

		}

		nodes.insert(contentsOf: moved, at: index + offset)
		moved.forEach { item in
			item.parent = nil
		}
	}

	func move(_ moved: [Node<Value>], toOther target: Node<Value>, at index: Int) {

		let grouped = Dictionary<ID?, [Node<Value>]>(grouping: moved) { item in
			return item.parent?.id
		}

		var offset = 0

		for (containerID, items) in grouped {
			let cache = Set(items.map(\.id))

			guard let containerID, let container = self.cache[containerID] else {
				nodes.removeAll { item in
					cache.contains(item.id)
				}
				continue
			}

			if container.id == target.id {
				offset = self.offset(
					moved: cache,
					in: container.children,
					to: index
				)
			}
			container.children.removeAll { item in
				cache.contains(item.id)
			}
		}

		target.insertItems(with: moved, to: index + offset)
	}

	func move(_ moved: [Node<Value>], to target: Node<Value>?) {

		let grouped = Dictionary<ID?, [Node<Value>]>(grouping: moved) { item in
			return item.parent?.id
		}

		for (containerID, items) in grouped {

			let cache = Set(items.map(\.id))

			guard let containerID, let container = self.cache[containerID] else {
				nodes.removeAll { item in
					cache.contains(item.id)
				}
				continue
			}

			container.children.removeAll { item in
				cache.contains(item.id)
			}
		}

		guard let target else {
			nodes.append(contentsOf: moved)
			moved.forEach { item in
				item.parent = nil
			}
			return
		}

		target.appendItems(with: moved)
	}

	func offset(moved: Set<ID>, in items: [Node<Value>], to index: Int) -> Int {
		var indexes = [Int]()
		for id in moved {
			guard let firstIndex = items.firstIndex(where: \.id, equalsTo: id) else {
				continue
			}
			indexes.append(firstIndex)
		}
		return -indexes.filter { $0 < index }.count
	}
}

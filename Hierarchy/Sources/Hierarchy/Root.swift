//
//  Root.swift
//  Hierarchy
//
//  Created by Anton Cherkasov on 17.11.2024.
//

import Foundation

public final class Root<Value: Identifiable & Hashable> {

	public typealias ID = Value.ID

	public private(set) var nodes: [Node<Value>]

	// MARK: - Cache

	private(set) var cache: [ID: Node<Value>] = [:]

	// MARK: - Initialization

	public init(hierarchy: [Node<Value>]) {
		self.nodes = hierarchy
		storeInCache(hierarchy)
	}
}

// MARK: - Subscripts
extension Root {

	public subscript(_ id: ID) -> Node<Value> {
		get {
			cache[unsafe: id]
		}
	}
}

public extension Root {

	func enumerate(_ block: (Node<Value>) -> Void) {
		nodes.forEach {
			$0.enumerate(block)
		}
	}

	func node(with id: ID) -> Node<Value>? {
		return cache[id]
	}

	func nodes(with ids: [ID]) -> [Node<Value>] {
		return ids.compactMap {
			cache[$0]
		}
	}

	func setProperty<T>(_ keyPath: WritableKeyPath<Value, T>, to value: T, for ids: [ID], downstream: Bool = false) {
		for id in ids {
			guard let item = cache[id] else {
				continue
			}
			item.setProperty(keyPath, to: value, downstream: downstream)
		}
	}

	func allSatisfy<T: Equatable>(_ keyPath: KeyPath<Value, T>, equalsTo value: T) -> Bool {
		return nodes.allSatisfy { $0.allSatisfy(keyPath, equalsTo: value) }
	}

	var count: Int {
		return nodes.reduce(0) { partialResult, node in
			return partialResult + node.count
		}
	}

	func count<T: Equatable>(where keyPath: KeyPath<Value, T>, equalsTo value: T) -> Int {
		return nodes.reduce(0) { partialResult, node in
			return partialResult + node.count(where: keyPath, equalsTo: value)
		}
	}
}

// MARK: - Helpers
private extension Root {

	func storeInCache(_ items: [Node<Value>]) where Value: NodeValue {
		for item in items {
			item.enumerate {
				if cache[$0.id] != nil {
					$0.value.generateIdentifier()
				}
				cache[$0.id] = $0
			}
		}
	}

	func storeInCache(_ items: [Node<Value>]) {
		for item in items {
			item.enumerate {
				if cache[$0.id] != nil { }
				cache[$0.id] = $0
			}
		}
	}
}

// MARK: - Insertion
extension Root {

	public func insertItems(with contents: [Value], to destination: Destination<ID>) {
		let items = contents.map { Node(value: $0) }
		storeInCache(items)
		switch destination {
		case .toRoot:
			nodes.append(contentsOf: items)
		case let .inRoot(index):
			nodes.insert(contentsOf: items, at: index)
		case let .onItem(id):
			guard let item = cache[id] else {
				return
			}
			item.appendItems(with: items)
		case let .inItem(id, index):
			guard let item = cache[id] else {
				return
			}
			item.insertItems(with: items, to: index)
		}
	}

	public func insertItems(from data: [any TreeNode<Value>], to destination: Destination<Value.ID>) {
		let items = data.map { node in
			makeNode(from: node)
		}

		switch destination {
		case .toRoot:
			nodes.append(contentsOf: items)
		case let .inRoot(index):
			nodes.insert(contentsOf: items, at: index)
		case let .onItem(id):
			guard let item = cache[id] else {
				return
			}
			item.appendItems(with: items)
		case let .inItem(id, index):
			guard let item = cache[id] else {
				return
			}
			item.insertItems(with: items, to: index)
		}
	}

	func makeNode(from other: any TreeNode<Value>) -> Node<Value> {
		let node = Node<Value>(value: other.value, children: other.children.map({ node in
			makeNode(from: node)
		}))
		storeInCache([node])
		return node
	}
}

// MARK: - Deletion
public extension Root {

	func deleteItems(_ ids: [ID]) {
		for id in ids {
			deleteItem(id)
		}
	}

	func deleteItem(_ id: ID) {
		guard let item = cache[id] else {
			return
		}
		guard let parent = item.parent else {
			if let index = nodes.firstIndex(where: \.id, equalsTo: id) {
				nodes.remove(at: index)
			}
			return
		}
		parent.deleteChild(id)
		cache[id] = nil
	}
}

// MARK: - Support moving
public extension Root {

	func validateMoving(_ ids: [ID], to destination: Destination<ID>) -> Bool {
		guard let targetId = destination.id, let item = cache[targetId] else {
			return true
		}

		var chain = Set<ID>()
		item.enumerateBackwards {
			chain.insert($0.id)
		}

		let intersection = chain.intersection(ids)

		return intersection.isEmpty
	}

	func moveItems(with ids: [ID], to destination: Destination<ID>) {
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
				return
			}
			move(moved, to: target)
		case let .inItem(id, index):
			guard let target = cache[id] else {
				return
			}
			move(moved, toOther: target, at: index)
		}
	}

	func moveToEnd(_ ids: [ID]) {
		let moved = ids.compactMap {
			cache[$0]
		}

		let grouped = Dictionary<Node<Value>?, [Node<Value>]>(grouping: moved) { item in
			return item.parent
		}

		for (container, items) in grouped {
			guard let container else {
				moveItems(with: items.map(\.id), to: .toRoot)
				continue
			}
			moveItems(with: items.map(\.id), to: .onItem(with: container.id))
		}
	}

	func moveToTop(_ ids: [ID]) {
		let moved = ids.compactMap {
			cache[$0]
		}

		let grouped = Dictionary<Node<Value>?, [Node<Value>]>(grouping: moved) { item in
			return item.parent
		}

		for (container, items) in grouped {
			guard let container else {
				moveItems(with: items.map(\.id), to: .inRoot(atIndex: 0))
				continue
			}
			moveItems(with: items.map(\.id), to: .inItem(with: container.id, atIndex: 0))
		}
	}
}

// MARK: - Equatable
extension Root: Equatable {

	public static func == (lhs: Root<Value>, rhs: Root<Value>) -> Bool {
		return lhs.nodes == rhs.nodes
	}
}

// MARK: - Support moving
private extension Root {

	func moveToRoot(_ moved: [Node<Value>], at index: Int) {

		let grouped = Dictionary<Node<Value>?, [Node<Value>]>(grouping: moved) { item in
			return item.parent
		}

		var offset = 0

		for (container, items) in grouped {

			let cache = Set(items.map(\.id))

			guard let container else {

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

		let grouped = Dictionary<Node<Value>?, [Node<Value>]>(grouping: moved) { item in
			return item.parent
		}

		var offset = 0

		for (container, items) in grouped {
			let cache = Set(items.map(\.id))

			guard let container else {
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

		let grouped = Dictionary<Node<Value>?, [Node<Value>]>(grouping: moved) { item in
			return item.parent
		}

		for (container, items) in grouped {

			let cache = Set(items.map(\.id))

			guard let container else {
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

//
//  Snapshot.swift
//  Hierarchy
//
//  Created by Anton Cherkasov on 16.11.2024.
//

import Foundation

public struct Snapshot<Model: Identifiable> {

	public typealias ID = Model.ID

	// MARK: - Hierarchy

	public private(set) var root: [ID] = []

	public private(set) var hierarchy: [ID: [ID]] = [:]

	private(set) var storage: [ID: NodeInfo<Model>] = [:]

	// MARK: - Cache

	private var cache: SnapshotCache<ID> = .init()

	// MARK: - Initialization

	public init(_ base: [Node<Model>]) {
		self.root = base.map(\.value.id)
		base.enumerated().forEach { (index, node) in
			normalize(base: node, parent: nil, index: index)
		}
	}

	/// Initialize empty snapshot
	public init() { }

	init(
		root: [ID],
		storage: [ID: [ID]],
		models: [ID: NodeInfo<Model>],
		cache: SnapshotCache<ID>
	) {
		self.root = root
		self.hierarchy = storage
		self.storage = models
		self.cache = cache
	}
}

// MARK: - Subscripts
public extension Snapshot {

	subscript(row: Int) -> Model {
		let id = cache.flattened[row]
		return storage[unsafe: id].model
	}
}

// MARK: - Public interface
public extension Snapshot {

	var identifiers: Set<ID> {
		cache.identifiers
	}

	var nodeIdentifiers: Set<ID> {
		return cache.nodeIdentifiers
	}

	func getNodes() -> [Node<Model>] {
		return root.map {
			node(for: $0)
		}
	}

	func contains(in parent: ID?, maxIndex: Int, condition: (Model) -> Bool) -> Int {

		let children = if let parent {
			hierarchy[unsafe: parent]
		} else {
			root
		}

		var count = 0

		let upperBound = min(maxIndex, children.count - 1)
		for child in children[0...upperBound] {
			let model = storage[unsafe: child].model
			if condition(model) {
				count += 1
			}
		}
		return count
	}

	func node(for id: ID) -> Node<Model> {

		let value = storage[unsafe: id].model
		let children = hierarchy[unsafe: id]

		return Node<Model>(
			value: value,
			children: children.map {
				node(for: $0)
			}
		)
	}

	func insert(before condition: (Model) -> Model?) -> Snapshot<Model> {
		let nodes = getNodes()
		let inserted = insert(in: nodes, before: condition)
		return Snapshot(inserted)
	}

	func insert(
		in nodes: [Node<Model>],
		before condition: (Model) -> Model?
	) -> [Node<Model>] {

		var result = [Node<Model>]()

		for child in nodes {
			guard let model = condition(child.value) else {
				result.append(child)
				continue
			}
			let new = Node(value: model)
			result.append(new)
			result.append(child)
		}

		return result.map {
			Node(
				value: $0.value,
				children: insert(in: $0.children, before: condition)
			)
		}
	}

	func flattened(while condition: (Model) -> Bool) -> [Model] {

		var result: [Model] = []

		for id in root {

			var queue = [id]

			while !queue.isEmpty {

				let current = queue.removeLast()

				let info = storage[unsafe: current]
				result.append(info.model)

				guard condition(info.model) else {
					continue
				}

				for child in hierarchy[unsafe: current].reversed() {
					queue.append(child)
				}

			}
		}

		return result
	}

	func satisfy(condition: (Model) -> Bool) -> Set<ID> {
		var result = Set<ID>()
		for id in cache.identifiers {
			let info = storage[unsafe: id]
			guard condition(info.model) else {
				continue
			}
			result.insert(id)
		}
		return result
	}

	func isLeaf(id: ID) -> Bool {
		let children = hierarchy[unsafe: id]
		return children.isEmpty
	}

	func level(for id: ID) -> Int {
		return storage[unsafe: id].level
	}

	func index(for id: ID) -> Int {
		return storage[unsafe: id].globalIndex
	}

	func rootItem(at index: Int) -> Model {
		let id = root[index]
		return storage[unsafe: id].model
	}

	func parent(for id: ID) -> Model? {
		guard let parent = storage[unsafe: id].parent else {
			return nil
		}
		return storage[unsafe: parent].model
	}

	func destination(ofItem id: ID) -> Destination<ID> {
		guard let parent = storage[unsafe: id].parent else {
			if let index = root.firstIndex(of: id) {
				return .inRoot(atIndex: index)
			}
			fatalError()
		}
		let children = hierarchy[unsafe: parent]
		guard let index = children.firstIndex(of: id) else {
			fatalError()
		}
		return .inItem(with: parent, atIndex: index)
	}

	func rootIdentifier(at index: Int) -> ID {
		return root[index]
	}

	func numberOfRootItems() -> Int {
		return root.count
	}

	func numberOfChildren(ofItem id: ID) -> Int {
		guard let children = hierarchy[id] else {
			fatalError()
		}
		return children.count
	}

	func children(of parent: ID) -> [ID] {
		return hierarchy[unsafe: parent]
	}

	func childOfItem(_ id: ID, at index: Int) -> Model {
		guard let id = hierarchy[id]?[index], let info = storage[id] else {
			fatalError()
		}
		return info.model
	}

	func model(with id: ID) -> Model {
		return storage[unsafe: id].model
	}

	func map<T: Identifiable>(_ transform: (NodeInfo<Model>) -> T) -> Snapshot<T> where T.ID == ID {

		var modificated: [ID: NodeInfo<T>] = [:]

		for info in storage.values {
			let id = info.model.id
			let model = transform(info)
			modificated[id] = NodeInfo(
				model: model,
				level: info.level,
				localIndex: info.localIndex,
				globalIndex: info.globalIndex,
				parent: info.parent
			)
		}

		return Snapshot<T>(
			root: root,
			storage: hierarchy,
			models: modificated,
			cache: cache
		)
	}

	mutating func validate(keyPath: WritableKeyPath<Model, Bool>) {
		for id in root {
			validate(id, keyPath: keyPath)
		}
	}

}

// MARK: - Enumeration
private extension Snapshot {

	@discardableResult
	mutating func validate(_ id: ID, keyPath: WritableKeyPath<Model, Bool>) -> Bool {

		let info = storage[unsafe: id]
		let children = hierarchy[unsafe: id]

		let result = {
			if children.isEmpty {
				return info.model[keyPath: keyPath]
			} else {
				var result = true
				for child in children {
					let current = validate(child, keyPath: keyPath)
					result = result && current
				}
				return result
			}
		}()

		var modificated = storage[unsafe: id]
		modificated.model[keyPath: keyPath] = result

		storage[id] = modificated

		return result
	}
}

// MARK: - Helpers
private extension Snapshot {

	mutating func normalize(base: Node<Model>, parent: ID?, index: Int, level: Int = 0) {

		hierarchy[base.id] = base.children.map(\.value.id)

		cache.identifiers.insert(base.id)
		cache.flattened.append(base.id)
		cache.maxLevel = max(cache.maxLevel, level)
		if base.children.count > 0 {
			cache.nodeIdentifiers.insert(base.id)
		}

		storage[base.id] = NodeInfo(
			model: base.value,
			level: level,
			localIndex: index,
			globalIndex: cache.flattened.count - 1,
			parent: parent
		)

		for (index, child) in base.children.enumerated() {
			normalize(base: child, parent: base.id, index: index, level: level + 1)
		}
	}
}

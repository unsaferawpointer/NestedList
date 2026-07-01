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

	subscript(safe row: Int) -> Model? {
		guard let id = cache.flattened[optional: row] else {
			return nil
		}
		return storage[id]?.model
	}
}

// MARK: - Transforming
public extension Snapshot {

	/// Returns a snapshot scoped to the children of the specified parent.
	///
	/// When `parent` is `nil`, the original snapshot is returned unchanged. When a parent identifier is
	/// provided, that parent's children become the root nodes of the returned snapshot, and all hierarchy
	/// metadata is rebuilt relative to the new root. If the parent is not found or has no children, an empty
	/// snapshot is returned.
	///
	/// - Parameter parent: The identifier of the node whose children should become the new root, or `nil` to keep the current root.
	/// - Returns: A snapshot rooted at the selected parent's children.
	func withRoot(parent: Model.ID?) -> Snapshot<Model> {
		guard let parent else {
			return self
		}
		guard let children = hierarchy[parent] else {
			return Snapshot([])
		}

		let base = children.compactMap {
			node(for: $0)
		}
		return Snapshot(base)
	}

	/// Returns a copy of this snapshot, removing descendants from nodes whose models satisfy the given predicate.
	///
	/// Root nodes and matching nodes are preserved. When `shouldRemoveChildren` returns `true` for a model,
	/// that model remains in the result but its children are omitted from the returned snapshot.
	///
	/// - Parameter shouldRemoveChildren: A predicate that determines where pruning should stop.
	/// - Returns: A pruned snapshot with hierarchy, storage, and cache rebuilt from the remaining nodes.
	func pruned(removingChildrenOf shouldRemoveChildren: (Model) -> Bool) -> Snapshot {
		let pruned = getNodes().map {
			$0.pruned(removingChildrenOf: shouldRemoveChildren)
		}
		return Snapshot(pruned)
	}

	/// Returns a copy of this snapshot without nodes that match the specified identifiers.
	///
	/// Removing a node also removes its descendants. Unknown identifiers are ignored, and the returned
	/// snapshot has its hierarchy, storage, and cache rebuilt from the remaining nodes.
	///
	/// - Parameter ids: The identifiers of nodes to remove from the snapshot.
	/// - Returns: A snapshot containing all nodes except the removed nodes and their descendants.
	func removed(ids: [ID]) -> Snapshot {
		let ids = Set(ids)
		let nodes = getNodes().filter {
			!ids.contains($0.id)
		}
		nodes.forEach {
			$0.deleteDescendants(with: ids)
		}
		return Snapshot(nodes)
	}

}

// MARK: - IdentifiableValue Transforming
public extension Snapshot where Model: IdentifiableValue {

	/// Returns a copy of this snapshot with models inserted at the specified destination.
	///
	/// The returned snapshot has its hierarchy, storage, and cache rebuilt after insertion. When the
	/// destination is invalid, the current snapshot is returned unchanged.
	///
	/// - Parameters:
	///   - models: The models to insert into the snapshot.
	///   - destination: The destination where the models should be inserted.
	/// - Returns: A snapshot containing the inserted models.
	func inserted(models: [Model], to destination: Destination<ID>) -> Snapshot {
		let store = NodeStore<Model>(hierarchy: getNodes())
		store.insertItems(with: models, to: destination)
		return store.snapshot()
	}
}

// MARK: - Public interface
public extension Snapshot {

	/// The total number of nodes contained in the snapshot.
	var count: Int {
		cache.identifiers.count
	}

	/// The number of hierarchy levels contained in the snapshot.
	var depth: Int {
		count == 0 ? 0 : cache.maxLevel + 1
	}

	var identifiers: Set<ID> {
		cache.identifiers
	}

	var nodeIdentifiers: Set<ID> {
		return cache.nodeIdentifiers
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

	func insert(before condition: (Model, Int) -> Model?) -> Snapshot<Model> {
		let nodes = getNodes()
		let inserted = insert(in: nodes, before: condition, level: 0)
		return Snapshot(inserted)
	}

	func insert(
		in nodes: [Node<Model>],
		before condition: (Model, Int) -> Model?,
		level: Int
	) -> [Node<Model>] {

		var result = [Node<Model>]()

		for child in nodes {
			guard let model = condition(child.value, level) else {
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
				children: insert(in: $0.children, before: condition, level: level + 1)
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

	func globalIndex(for id: ID) -> Int {
		return storage[unsafe: id].globalIndex
	}

	func localIndex(for id: ID) -> Int {
		return storage[unsafe: id].localIndex
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

	func children(of parent: ID?) -> [Model] {
		guard let parent else {
			return root.compactMap {
				storage[$0]?.model
			}
		}
		return hierarchy[parent]?.compactMap {
			storage[$0]?.model
		} ?? []
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

	func map<T: Identifiable>(_ transform: (Model) -> T) -> Snapshot<T> {
		let nodes = getNodes()
		let transformed = nodes.map {
			$0.map { model in
				transform(model)
			}
		}
		return .init(transformed)
	}

	func map<T: Identifiable>(_ transform: (NodeInfo<Model>) -> T) -> Snapshot<T> where T.ID == ID {

		var modificated: [ID: NodeInfo<T>] = [:]

		for info in storage.values {
			let id = info.model.id
			let model = transform(info)
			modificated[id] = NodeInfo(
				model: model,
				isLeaf: info.isLeaf,
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

	func getNodes() -> [Node<Model>] {
		return root.map {
			node(for: $0)
		}
	}

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
			isLeaf: base.children.isEmpty,
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

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

	public private(set) var storage: [ID: [ID]] = [:]

	// MARK: - Cache

	private(set) var models: [ID: Model] = [:]

	public private(set) var cache: [ID: Bool] = [:]

	public private(set) var identifiers: Set<ID> = .init()

	private(set) var flattened: [ID] = []

	private(set) var levels: [ID: Int] = [:]

	private(set) var indices: [ID: Int] = [:]

	private(set) var maxLevel: Int = 0

	// MARK: - Initialization

	public init(_ base: [Node<Model>]) {
		self.root = base.map(\.value.id)
		base.forEach { node in
			normalize(base: node, keyPath: nil)
		}
	}

	public init(_ base: [Node<Model>], keyPath: KeyPath<Model, Bool>) {
		self.root = base.map(\.value.id)
		base.forEach { node in
			normalize(base: node, keyPath: keyPath)
		}
	}

	/// Initialize empty snapshot
	public init() { }

	init(
		root: [ID],
		storage: [ID: [ID]],
		cache: [ID: Model],
		identifiers: Set<ID>,
		flattened: [ID],
		levels: [ID: Int],
		maxLevel: Int,
		indices: [ID: Int]
	) {
		self.root = root
		self.storage = storage
		self.models = cache
		self.identifiers = identifiers
		self.flattened = flattened
		self.levels = levels
		self.maxLevel = maxLevel
		self.indices = indices
	}
}

// MARK: - Subscripts
public extension Snapshot {

	subscript(row: Int) -> Model {
		let id = flattened[row]
		return models[unsafe: id]
	}
}

// MARK: - Public interface
public extension Snapshot {

	func flattened(while condition: (Model) -> Bool) -> [Model] {

		var result: [Model] = []

		for id in root {

			var queue = [id]

			while !queue.isEmpty {

				let current = queue.removeLast()

				let model = models[unsafe: current]
				result.append(model)

				guard condition(model) else {
					continue
				}

				for child in storage[unsafe: current].reversed() {
					queue.append(child)
				}

			}
		}

		return result
	}

	func satisfy(condition: (Model) -> Bool) -> Set<ID> {
		var result = Set<ID>()
		for id in identifiers {
			let model = models[unsafe: id]
			guard condition(model) else {
				continue
			}
			result.insert(id)
		}
		return result
	}

	func level(for id: ID) -> Int {
		return levels[unsafe: id]
	}

	func index(for id: ID) -> Int {
		return indices[unsafe: id]
	}

	func rootItem(at index: Int) -> Model {
		let id = root[index]
		return models[unsafe: id]
	}

	func rootIdentifier(at index: Int) -> ID {
		return root[index]
	}

	func numberOfRootItems() -> Int {
		return root.count
	}

	func numberOfChildren(ofItem id: ID) -> Int {
		guard let children = storage[id] else {
			fatalError()
		}
		return children.count
	}

	func children(of parent: ID) -> [ID] {
		return storage[unsafe: parent]
	}

	func childOfItem(_ id: ID, at index: Int) -> Model {
		guard let id = storage[id]?[index], let model = models[id] else {
			fatalError()
		}
		return model
	}

	func isLeaf(id: ID) -> Bool {
		return storage[unsafe: id].count == 0
	}

	func model(with id: ID) -> Model {
		return models[unsafe: id]
	}

	func map<T>(_ transform: (Model, Bool, Int) -> T) -> Snapshot<T> where T.ID == ID {
		var newModels = [ID: T]()
		for (_, model) in models {
			newModels[model.id] = transform(model, cache[unsafe: model.id], level(for: model.id))
		}
		return Snapshot<T>(
			root: root,
			storage: storage,
			cache: newModels,
			identifiers: identifiers,
			flattened: flattened,
			levels: levels,
			maxLevel: maxLevel,
			indices: indices
		)
	}

	func allSatisfy(_ id: ID) -> Bool {
		return cache[unsafe: id]
	}
}

// MARK: - Helpers
private extension Snapshot {

	mutating func normalize(base: Node<Model>, keyPath: KeyPath<Model, Bool>?, level: Int = 0) {

		identifiers.insert(base.id)
		storage[base.id] = base.children.map(\.value.id)
		models[base.id] = base.value
		flattened.append(base.id)
		levels[base.id] = level
		maxLevel = max(maxLevel, level)
		indices[base.id] = flattened.count - 1

		// TODO: - Optimize
		if let keyPath {
			cache[base.id] = base.allSatisfy(keyPath, equalsTo: true)
		}

		for child in base.children {
			normalize(base: child, keyPath: keyPath, level: level + 1)
		}
	}
}

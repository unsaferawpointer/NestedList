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

	init(root: [ID], storage: [ID: [ID]], cache: [ID: Model], identifiers: Set<ID>) {
		self.root = root
		self.storage = storage
		self.models = cache
		self.identifiers = identifiers
	}
}

// MARK: - Public interface
public extension Snapshot {

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

	func model(with id: ID) -> Model {
		return models[unsafe: id]
	}

	func map<T>(_ transform: (Model, Bool) -> T) -> Snapshot<T> where T.ID == ID {
		var newModels = [ID: T]()
		for (id, model) in models {
			newModels[id] = transform(model, cache[unsafe: id])
		}
		return Snapshot<T>(
			root: root,
			storage: storage,
			cache: newModels,
			identifiers: identifiers
		)
	}

	func allSatisfy(_ id: ID) -> Bool {
		return cache[unsafe: id]
	}
}

// MARK: - Helpers
private extension Snapshot {

	mutating func normalize(base: Node<Model>, keyPath: KeyPath<Model, Bool>?) {

		identifiers.insert(base.id)
		storage[base.id] = base.children.map(\.value.id)
		models[base.id] = base.value

		// TODO: - Optimize
		if let keyPath {
			cache[base.id] = base.allSatisfy(keyPath, equalsTo: true)
		}

		for child in base.children {
			normalize(base: child, keyPath: keyPath)
		}
	}
}

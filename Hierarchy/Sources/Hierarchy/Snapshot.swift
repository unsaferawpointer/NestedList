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

	private(set) var root: [ID] = []

	private(set) var storage: [ID: [ID]] = [:]

	// MARK: - Cache

	private(set) var cache: [ID: Model] = [:]

	public private(set) var identifiers: Set<ID> = .init()

	// MARK: - Initialization

	public init(_ base: [Node<Model>]) {
		self.root = base.map(\.id)
		base.forEach { node in
			normalize(base: node)
		}
	}

	/// Initialize empty snapshot
	public init() { }
}

// MARK: - Public interface
public extension Snapshot {

	func rootItem(at index: Int) -> Model {
		let id = root[index]
		guard let model = cache[id] else {
			fatalError()
		}
		return model
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

	func childOfItem(_ id: ID, at index: Int) -> Model {
		guard let id = storage[id]?[index], let model = cache[id] else {
			fatalError()
		}
		return model
	}

	func model(with id: ID) -> Model {
		return cache[unsafe: id]
	}
}

// MARK: - Helpers
private extension Snapshot {

	mutating func normalize(base: Node<Model>) {

		identifiers.insert(base.id)
		storage[base.id] = base.children.map(\.id)
		cache[base.id] = base.value

		for child in base.children {
			normalize(base: child)
		}
	}
}

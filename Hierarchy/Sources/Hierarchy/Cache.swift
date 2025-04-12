//
//  Cache.swift
//  Hierarchy
//
//  Created by Anton Cherkasov on 05.04.2025.
//

public final class Cache<Property: Hashable, Model: Identifiable> {

	private var storage: [Property: Set<Model.ID>] = [:]

	// MARK: - Initialization

	public init() { }
}

// MARK: - Public interface
public extension Cache {

	func store<T: Equatable>(_ property: Property, keyPath: KeyPath<Model, T>, equalsTo value: T, from snapshot: Snapshot<Model>) {
		storage[property] = snapshot.satisfy { model in
			model[keyPath: keyPath] == value
		}
	}

	func store<T: Equatable>(_ property: Property, keyPath: KeyPath<Model, T>, notEqualsTo value: T, from snapshot: Snapshot<Model>) {
		storage[property] = snapshot.satisfy { model in
			model[keyPath: keyPath] != value
		}
	}

	func validate(_ property: Property, other: [Model.ID]) -> Bool? {
		guard let stored = storage[property] else {
			return nil
		}
		return validate(in: stored, with: other)
	}
}

// MARK: - Helpers
private extension Cache {

	func validate(in cache: Set<Model.ID>, with other: [Model.ID]) -> Bool? {
		let count = Set(other).intersection(cache).count
		switch count {
		case 0:
			return false
		case other.count:
			return true
		default:
			return nil
		}
	}
}

//
//  Destination.swift
//  Hierarchy
//
//  Created by Anton Cherkasov on 16.11.2024.
//

import Foundation

public enum Destination<ID> {

	case toRoot
	case inRoot(atIndex: Int)
	case onItem(with: ID)
	case inItem(with: ID, atIndex: Int)

	// MARK: - Initialization block

	public init(target: ID?) {
		if let target {
			self = .onItem(with: target)
		} else {
			self = .toRoot
		}
	}
}

// MARK: - Public interface
public extension Destination {

	func relative(to root: ID?) -> Destination<ID> {
		guard let root else {
			return self
		}
		switch self {
		case .toRoot:
			return .onItem(with: root)
		case .inRoot(let index):
			return .inItem(with: root, atIndex: index)
		default:
			return self
		}
	}
}

// MARK: - Computed properties
public extension Destination {

	var id: ID? {
		switch self {
		case .onItem(let id), .inItem(let id, _):
			return id
		default:
			return nil
		}
	}

	var index: Int? {
		switch self {
		case .inRoot(let index), .inItem(_ , let index):
			return index
		default:
			return nil
		}
	}
}

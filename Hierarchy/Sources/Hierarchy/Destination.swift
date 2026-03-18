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

	public init(target: ID?, index: Int) {
		if let target {
			self = .inItem(with: target, atIndex: index)
		} else {
			self = .inRoot(atIndex: index)
		}
	}
}

// MARK: - Equatable
extension Destination: Equatable where ID: Equatable { }

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

	func shifted(by offset: Int) -> Destination<ID> {
		switch self {
		case .inRoot(atIndex: let index):
			return .inRoot(atIndex: index + offset)
		case .inItem(with: let id, atIndex: let index):
			return .inItem(with: id, atIndex: index + offset)
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

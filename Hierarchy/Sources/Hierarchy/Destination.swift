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

	public var id: ID? {
		switch self {
		case .toRoot, .inRoot:
			return nil
		case .onItem(let id), .inItem(let id, _):
			return id
		}
	}

	public var index: Int? {
		switch self {
		case .toRoot:
			return nil
		case .inRoot(let index):
			return index
		case .onItem:
			return nil
		case .inItem(_ , let index):
			return index
		}
	}

	// MARK: - Initialization block

	public init(target: ID?) {
		if let target {
			self = .onItem(with: target)
		} else {
			self = .toRoot
		}
	}
}

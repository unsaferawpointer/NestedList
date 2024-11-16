//
//  Content.swift
//  CoreModule
//
//  Created by Anton Cherkasov on 16.11.2024.
//

import Hierarchy

public struct Content {

	public var nodes: [Node<Item>]

	// MARK: - Initialization

	public init(nodes: [Node<Item>] = []) {
		self.nodes = nodes
	}
}

// MARK: - Templates
public extension Content {

	static var empty: Content {
		return .init(nodes: [])
	}
}

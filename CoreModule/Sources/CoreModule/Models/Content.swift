//
//  Content.swift
//  CoreModule
//
//  Created by Anton Cherkasov on 16.11.2024.
//

import Hierarchy

public struct Content {

	public var root: Root<Item>

	// MARK: - Initialization

	init(nodes: [Node<Item>] = []) {
		self.root = Root<Item>(hierarchy: nodes)
	}
}

public extension Content {

	static var empty: Content {
		return .init()
	}
}

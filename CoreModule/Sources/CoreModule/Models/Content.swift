//
//  Content.swift
//  CoreModule
//
//  Created by Anton Cherkasov on 16.11.2024.
//

import Foundation
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

// MARK: - Codable
extension Content: Codable {

	enum CodingKeys: CodingKey {
		case root
	}

	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		let nodes = try container.decode([Node<Item>].self, forKey: .root)
		self.init(nodes: nodes)
	}

	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(root.nodes, forKey: .root)
	}
}

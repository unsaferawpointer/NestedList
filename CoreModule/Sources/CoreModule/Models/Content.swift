//
//  Content.swift
//  CoreModule
//
//  Created by Anton Cherkasov on 16.11.2024.
//

import Foundation
import Hierarchy

public struct Content {

	public var view: ContentView

	public var root: Root<Item>

	// MARK: - Initialization

	public init(nodes: [Node<Item>] = [], view: ContentView = .list) {
		self.root = Root<Item>(hierarchy: nodes)
		self.view = view
	}
}

// MARK: - Templates
public extension Content {

	static var empty: Content {
		return .init()
	}
}

// MARK: - Equatable
extension Content: Equatable { }

// MARK: - Codable
extension Content: Codable {

	enum CodingKeys: CodingKey {
		case items
		case view
	}

	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		let nodes = try container.decode([Node<Item>].self, forKey: .items)
		let view = try container.decodeIfPresent(ContentView.self, forKey: .view) ?? .list
		self.init(nodes: nodes, view: view)
	}

	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(root.nodes, forKey: .items)
		try container.encode(view, forKey: .view)
	}
}

// MARK: - Nested structs
public extension Content {

	enum ContentView: Int, Codable {
		case list = 0
		case board
	}
}

//
//  Content.swift
//  CoreModule
//
//  Created by Anton Cherkasov on 16.11.2024.
//

import Foundation
import Hierarchy

public struct Content {

	public var uuid: UUID?

	public var view: ContentView

	public var root: Root<Item>

	// MARK: - Initialization

	public init(uuid: UUID?, nodes: [Node<Item>] = [], view: ContentView = .list) {
		self.uuid = uuid
		self.root = Root<Item>(hierarchy: nodes)
		self.view = view
	}
}

// MARK: - Templates
public extension Content {

	static var empty: Content {
		return .init(uuid: UUID())
	}
}

// MARK: - Equatable
extension Content: Equatable { }

// MARK: - Codable
extension Content: Codable {

	enum CodingKeys: CodingKey {
		case items
		case view
		case uuid
	}

	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		let nodes = try container.decode([Node<Item>].self, forKey: .items)
		let view = try container.decodeIfPresent(ContentView.self, forKey: .view) ?? .list
		let uuid = try? container.decodeIfPresent(UUID.self, forKey: .uuid)
		self.init(uuid: uuid, nodes: nodes, view: view)
	}

	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(root.nodes, forKey: .items)
		try container.encode(view, forKey: .view)
		try container.encode(uuid ?? UUID(), forKey: .uuid)
	}
}

// MARK: - Nested structs
public extension Content {

	enum ContentView: Int, Codable {
		case list = 0
		case board
	}
}

//
//  Node.swift
//  Hierarchy
//
//  Created by Anton Cherkasov on 16.11.2024.
//

import Foundation

final class Node<Value: Identifiable>: TreeNode {

	typealias ID = Value.ID

	var value: Value

	// MARK: - Relationships

	weak var parent: Node?

	var children: [Node]

	// MARK: - Initialization

	init(value: Value, children: [Node] = []) {
		self.value = value
		self.children = children
		for node in children {
			node.parent = self
		}
	}
}

// MARK: - Helpers
private extension Node {

	/// Visit node by depth first traversal
	func visit(_ node: Node, block: (Node) -> Void) {
		block(node)
		node.children.forEach {
			visit($0, block: block)
		}
	}
}

// MARK: - Identifiable
extension Node: Identifiable {

	var id: Value.ID {
		return value.id
	}
}

// MARK: - Public interface
extension Node {

	func map<T>(_ transform: (Value) -> T) -> Node<T> {
		let transformed = transform(value)
		return .init(
			value: transformed,
			children: children.map{ node in
				node.map(transform)
			}
		)
	}

	func enumerateBackwards(_ block: (Node) -> Void) {
		block(self)
		parent?.enumerateBackwards(block)
	}

	func setProperty<T>(_ keyPath: WritableKeyPath<Value, T>, to value: T, downstream: Bool) {
		self.value[keyPath: keyPath] = value
		if downstream {
			children.forEach { item in
				item.setProperty(
					keyPath,
					to: value,
					downstream: downstream
				)
			}
		}
	}

	@discardableResult
	func deleteChild(_ id: ID) -> Int? {
		guard let index = children.firstIndex(where: \.id, equalsTo: id) else {
			return nil
		}
		children.remove(at: index)
		return index
	}

	func deleteDescendants(with ids: Set<ID>) {
		children.removeAll {
			ids.contains($0.value.id)
		}
		for index in 0..<children.count {
			children[index].deleteDescendants(with: ids)
		}
	}

	func insertItems(with items: [Node], to index: Int) {
		let safeIndex = min(max(index, 0), children.count)
		self.children.insert(contentsOf: items, at: safeIndex)
		items.forEach { item in
			item.parent = self
		}
	}

	func appendItems(with items: [Node]) {
		self.children.append(contentsOf: items)
		items.forEach { item in
			item.parent = self
		}
	}
}

// MARK: - Nested data structs
extension Node {

	enum CodingKeys: CodingKey {
		case value
		case children
	}
}

// MARK: - Equatable
extension Node: Equatable where Value: Equatable {

	static func == (lhs: Node<Value>, rhs: Node<Value>) -> Bool {
		return lhs.id == rhs.id
				&& lhs.value == rhs.value
				&& lhs.children == rhs.children
	}
}

// MARK: - Hashable
extension Node: Hashable where Value: Hashable {

	func hash(into hasher: inout Hasher) {
		hasher.combine(id)
		hasher.combine(value)
		hasher.combine(children)
	}
}

// MARK: - Decodable
extension Node: Decodable where Value: Decodable {

	convenience init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)

		let value = try container.decode(Value.self, forKey: .value)
		let children = try container.decodeIfPresent([Node].self, forKey: .children) ?? []

		self.init(value: value, children: children)
	}
}

// MARK: - Encodable
extension Node: Encodable where Value: Encodable {

	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)

		try container.encode(value, forKey: .value)
		if !children.isEmpty {
			try container.encode(children, forKey: .children)
		}
	}
}

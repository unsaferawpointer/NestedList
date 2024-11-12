//
//  Node.swift
//  NestedList
//
//  Created by Anton Cherkasov on 12.11.2024.
//

import Foundation

struct Node<Value: Identifiable> {

	typealias ID = Value.ID

	var value: Value

	var children: [Node<Value>]?

	// MARK: - Initialization

	init(value: Value, children: [Node<Value>]? = nil) {
		self.value = value
		self.children = children
	}
}

// MARK: - Identifiable
extension Node: Identifiable {

	var id: ID {
		value.id
	}
}

extension Node {

	mutating func insert(_ node: Node<Value>, to target: ID) {
		guard id == target else {
			return
		}
		if children == nil {
			children = [node]
		} else {
			children?.append(node)
		}
	}

	mutating func remove(_ ids: Set<ID>) {
		children?.removeAll {
			ids.contains($0.id)
		}
		for i in 0..<(children?.count ?? 0) {
			children![i].remove(ids)
		}

		if children?.isEmpty ?? true {
			children = nil
		}
	}
}

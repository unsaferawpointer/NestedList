//
//  Node.swift
//  Hierarchy
//
//  Created by Anton Cherkasov on 16.11.2024.
//

import Foundation

public final class Node<Value> {

	public var value: Value
	public var children: [Node<Value>]

	// MARK: - Initialization

	public init(value: Value, children: [Node<Value>] = []) {
		self.value = value
		self.children = children
	}
}

// MARK: - Identifiable
extension Node: Identifiable where Value: Identifiable {

	public var id: Value.ID {
		value.id
	}
}

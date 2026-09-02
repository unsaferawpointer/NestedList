//
//  TreeNode.swift
//  Hierarchy
//
//  Created by Anton Cherkasov on 17.11.2024.
//

import Foundation

public protocol TreeNode<Value> {

	associatedtype Value: Identifiable

	var value: Value { get set }

	var children: [Self] { get }

	init(value: Value, children: [Self])
}

public extension TreeNode {

	var id: Value.ID {
		value.id
	}
}

public extension TreeNode {

	/// Returns a copy of this subtree, removing descendants from nodes that satisfy the given predicate.
	///
	/// The current node is always preserved. When `shouldRemoveChildren` returns `true` for a node's value,
	/// that node remains in the result but its children are omitted.
	///
	/// - Parameter shouldRemoveChildren: A predicate that determines where pruning should stop.
	/// - Returns: A pruned copy of this node and its descendants.
	func pruned(removingChildrenOf shouldRemoveChildren: (Value) -> Bool) -> Self {
		return Self(
			value: value,
			children: shouldRemoveChildren(value)
			? []
			: children.map {
				$0.pruned(removingChildrenOf: shouldRemoveChildren)
			}
		)
	}

	/// Returns a copy of this node and all of its descendants.
	///
	/// The copied tree contains newly created nodes with the same values and child order.
	///
	/// - Returns: A copy of this node and its descendants.
	func copy() -> Self {
		return Self(
			value: value,
			children: children.map { $0.copy() }
		)
	}

	func map<T: TreeNode>(type: T.Type) -> T where T.Value == Value {
		return T.init(
			value: value,
			children:children.map {
				$0.map(type: type)
			}
		)
	}

	func enumerate(_ block: (Self) -> Void) {
		block(self)
		for node in children {
			node.enumerate(block)
		}
	}

	var descedantsCount: Int {
		guard !children.isEmpty else {
			return 0
		}
		return children.reduce(0) { partialResult, node in
			return partialResult + node.count
		}
	}

	var count: Int {
		guard !children.isEmpty else {
			return 1
		}
		return children.reduce(0) { partialResult, node in
			return partialResult + node.count
		}
	}

	func reduce(_ keyPath: KeyPath<Value, Bool>) -> Bool {
		guard !children.isEmpty else {
			return value[keyPath: keyPath]
		}
		return children.allSatisfy { entity in
			return entity.reduce(keyPath)
		}
	}

	func reduce(_ keyPath: KeyPath<Value, Int>) -> Int {
		guard !children.isEmpty else {
			return value[keyPath: keyPath]
		}
		return children.reduce(0) { partialResult, node in
			return partialResult + node.reduce(keyPath)
		}
	}

	/// Returns the number of leaf nodes in this subtree that have a value equal to the given value at the specified key path.
	func count<T: Equatable>(where keyPath: KeyPath<Value, T>, equalsTo value: T) -> Int {
		guard !children.isEmpty else {
			return self.value[keyPath: keyPath] == value ? 1 : 0
		}
		return children.reduce(0) { partialResult, node in
			return partialResult + node.count(where: keyPath, equalsTo: value)
		}
	}

	/// Returns `true` when every leaf node in this subtree has a value equal to the given value at the specified key path.
	func allMatch<T: Equatable>(_ keyPath: KeyPath<Value, T>, equalsTo value: T) -> Bool {
		guard !children.isEmpty else {
			return self.value[keyPath: keyPath] == value
		}
		return children.allSatisfy {
			$0.allMatch(keyPath, equalsTo: value)
		}
	}

	func childrenIds() -> [Value.ID] {
		var result = children.map(\.id)
		for child in children {
			result.append(contentsOf: child.childrenIds())
		}
		return result
	}

	func isAncestor(of other: Value.ID) -> Bool {
		guard children.contains(where: { $0.id == other }) else {
			for child in children {
				if child.isAncestor(of: other) {
					return true
				}
			}
			return false
		}
		return true
	}
}

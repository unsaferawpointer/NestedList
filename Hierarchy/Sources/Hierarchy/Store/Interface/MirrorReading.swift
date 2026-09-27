//
//  MirrorReading.swift
//  Hierarchy
//
//  Created by Anton Cherkasov on 13.09.2026.
//

import Foundation

public protocol MirrorReading<Content, ID> {

	associatedtype Content
	associatedtype ID: Hashable

	var identifiers: Set<ID> { get }

	func parent(of id: ID) -> ID?

	func children(of parent: ID?) -> [ID]

	func snapshot() -> Snapshot<Resolved<Content, ID>>

	subscript(id: ID) -> Resolved<Content, ID>? { get }
}

// MARK: - Snapshot Support
public extension MirrorReading {

	func snapshot() -> Snapshot<Resolved<Content, ID>> {
		func node(with id: ID) -> Node<Resolved<Content, ID>>? {
			guard let value = self[id] else {
				return nil
			}
			return Node(
				value: value,
				children: children(of: id).compactMap { node(with: $0) }
			)
		}

		let nodes = children(of: nil)
			.compactMap {
				node(with: $0)
			}
		return Snapshot(nodes)
	}
}

// MARK: - Tree nodes
public extension MirrorReading {

	func nodes<T: TreeNode>(type: T.Type) -> [T]
	where T.Value == Resolved<Content, ID> {
		return children(of: nil).compactMap { id in
			node(with: id, type: type)
		}
	}

	func node<T: TreeNode>(with id: ID, type: T.Type) -> T?
	where T.Value == Resolved<Content, ID> {
		guard let value = self[id] else {
			return nil
		}
		return T(
			value: value,
			children: children(of: id).compactMap { childID in
				node(with: childID, type: type)
			}
		)
	}
}

// MARK: - Copying
public extension MirrorReading {

	func copiedDisjointSubtrees(with ids: [ID]) -> [any TreeNode<Resolved<Content, ID>>] {
		let identifiers = Set(ids)
		let copied = ids.compactMap {
			node(with: $0, type: Node<Resolved<Content, ID>>.self)
		}
		copied.forEach { node in
			node.deleteDescendants(with: identifiers)
		}
		return copied
	}
}

// MARK: - Matching
public extension MirrorReading {

	func allMatch<T: Equatable>(
		id: ID,
		keyPath: KeyPath<Resolved<Content, ID>, T>,
		equalsTo value: T
	) -> Bool {
		guard self[id] != nil else {
			return false
		}

		var pending = [id]
		while let id = pending.popLast() {
			let childIDs = children(of: id)
			guard childIDs.isEmpty else {
				pending.append(contentsOf: childIDs)
				continue
			}
			guard self[id]?[keyPath: keyPath] == value else {
				return false
			}
		}
		return true
	}
}

// MARK: - Enumeration
public extension MirrorReading {

	func enumerate(_ block: (Resolved<Content, ID>) -> Void) {
		var visited = Set<ID>()
		var pending = Array(children(of: nil).reversed())

		while let id = pending.popLast() {
			guard visited.insert(id).inserted, let value = self[id] else {
				continue
			}
			block(value)
			pending.append(contentsOf: children(of: id).reversed())
		}
	}
}

// MARK: - Descendants
public extension MirrorReading {

	func descendantIDs(including ids: Set<ID>) -> Set<ID> {
		var result = Set<ID>()
		var pending = Array(ids)

		while let id = pending.popLast() {
			guard self[id] != nil, result.insert(id).inserted else {
				continue
			}
			pending.append(contentsOf: children(of: id))
		}
		return result
	}
}

// MARK: - Physical ancestry
public extension MirrorReading {

	func ancestorIDs(including id: ID) -> Set<ID>? {
		var result = Set<ID>()
		var current: ID? = id

		while let currentID = current {
			guard result.insert(currentID).inserted else {
				return nil
			}
			current = parent(of: currentID)
		}
		return result
	}
}

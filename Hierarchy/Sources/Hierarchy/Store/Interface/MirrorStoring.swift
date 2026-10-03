//
//  MirrorStoring.swift
//  Hierarchy
//
//  Created by Anton Cherkasov on 03.09.2026.
//

public protocol MirrorStoring<Content, ID>: MirrorReading where ID: RandomizableIdentifier {

	func insertMirror(
		reference: ID,
		to destination: Destination<ID>
	) throws(MirrorStoreError) -> ID

	func insertItems(
		from data: [any TreeNode<Container<Content, ID>>],
		to destination: Destination<ID>
	) throws(MirrorStoreError)

	func insert<T: TreeNode>(
		nodes: [T],
		to destination: Destination<ID>
	) throws(MirrorStoreError) where T.Value == Container<Content, ID>

	func deleteItems<S: Sequence>(_ ids: S) where S.Element == ID

	func moveItems<S>(
		_ ids: S,
		to destination: Destination<ID>
	) throws(MirrorStoreError) where S : Sequence, S.Element == ID

	func validateMove<S: Sequence>(
		_ ids: S,
		to destination: Destination<ID>
	) -> Bool where S.Element == ID

	func canMoveItems<S: Sequence>(
		_ ids: S,
		to destination: Destination<ID>
	) -> Bool where S.Element == ID

	func set<T>(
		_ keyPath: WritableKeyPath<Content, T>,
		to value: T,
		for ids: [ID],
		includingDescendants: Bool
	)
}

// MARK: - Insertion
public extension MirrorStoring {

	func insert<S: Sequence>(
		_ items: S,
		at destination: Destination<ID>
	) throws(MirrorStoreError) where S.Element == Container<Content, ID> {
		let nodes = items.map { Node(value: $0) }
		try insertItems(from: nodes, to: destination)
	}
}

// MARK: - Moving
public extension MirrorStoring {

	func canMoveItems<S: Sequence>(
		_ ids: S,
		to destination: Destination<ID>
	) -> Bool where S.Element == ID {
		validateMove(ids, to: destination)
	}

	/// Moves the specified nodes to the end of their current parent containers.
	func moveToEnd(_ ids: [ID]) throws(MirrorStoreError) {
		let grouped = Dictionary(grouping: ids.filter { id in
			self[id] != nil
		}) { id in
			parent(of: id)
		}

		for (parent, ids) in grouped {
			try moveItems(ids, to: Destination(target: parent))
		}
	}

	/// Returns whether the specified node can be moved one position forward among its siblings.
	func validateMovingForward(_ id: ID) -> Bool {
		guard let location = location(of: id) else {
			return false
		}
		return location.index + 1 < location.count
	}

	/// Returns whether the specified node can be moved one position backward among its siblings.
	func validateMovingBackward(_ id: ID) -> Bool {
		guard let location = location(of: id) else {
			return false
		}
		return location.index > 0
	}

	/// Moves the specified node one position forward among its siblings.
	func moveForward(_ id: ID) throws(MirrorStoreError) {
		guard let location = location(of: id), location.index + 1 < location.count else {
			return
		}
		try moveItems([id], to: Destination(target: location.parent, index: location.index + 2))
	}

	/// Moves the specified node one position backward among its siblings.
	func moveBackward(_ id: ID) throws(MirrorStoreError) {
		guard let location = location(of: id), location.index > 0 else {
			return
		}
		try moveItems([id], to: Destination(target: location.parent, index: location.index - 1))
	}
}

// MARK: - Helpers
private extension MirrorStoring {

	func location(of id: ID) -> (parent: ID?, index: Int, count: Int)? {
		let parent = parent(of: id)
		let siblings = children(of: parent)
		guard let index = siblings.firstIndex(of: id) else {
			return nil
		}
		return (parent, index, siblings.count)
	}
}

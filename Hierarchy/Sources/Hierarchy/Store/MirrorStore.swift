//
//  MirrorStore.swift
//  Hierarchy
//
//  Created by Anton Cherkasov on 13.09.2026.
//

import Foundation

public final class MirrorStore<Content, ID: RandomizableIdentifier> {

	// MARK: - Internal State

	private var storage = InternalStorage()

	// MARK: - Initialization

	public init() { }

	public convenience init<T: TreeNode>(hierarchy: [T]) throws(MirrorStoreError)
	where T.Value == Container<Content, ID> {
		self.init()
		try insert(nodes: hierarchy, to: .toRoot)
	}

	public convenience init<T: TreeNode>(nodes: [T]) throws(MirrorStoreError) where T.Value == Container<Content, ID> {
		try self.init(hierarchy: nodes)
	}

	/// Creates a store from the legacy resolved-item hierarchy.
	///
	/// The legacy representation contains resolved values rather than explicit
	/// containers. Since it does not retain mirror references, every value is
	/// imported as an item while preserving its identifier and content.
	public convenience init<T: TreeNode>(hierarchy: [T]) throws(MirrorStoreError)
	where T.Value == Resolved<Content, ID> {
		self.init()
		let nodes: [Node<Container<Content, ID>>] = hierarchy.map {
			$0.map { value in
				Container.item(id: value.id, content: value.content)
			}
		}
		try insertNodes(nodes, to: .toRoot)
	}
}

// MARK: - Equatable
extension MirrorStore: Equatable where Content: Equatable {

	public static func == (lhs: MirrorStore<Content, ID>, rhs: MirrorStore<Content, ID>) -> Bool {
		lhs.storage.nodes == rhs.storage.nodes
	}
}

// MARK: - Persisted container reading
public extension MirrorStore {

	func insertMirror(reference: ID, to destination: Destination<ID>) throws(MirrorStoreError) -> ID {
		guard let source = storage[reference] else {
			throw .missingReference
		}

		let originalReference: ID = switch source.value {
		case .item:
			reference
		case let .mirror(_, reference):
			reference
		}

		var id = ID.random()
		while storage[id] != nil {
			id = ID.random()
		}

		let node = Node<Container<Content, ID>>(
			value: .mirror(id: id, reference: originalReference)
		)
		try insertNodes([node], to: destination)
		return id
	}

	func storedNodes<T: TreeNode>(type: T.Type) -> [T]
	where T.Value == Container<Content, ID> {
		storage.nodes.map { $0.map(type: type) }
	}

}

// MARK: - Mirror Source Validation
public extension MirrorStore {

	func mirrorSourceIDs(to destination: Destination<ID>) -> Set<ID> {
		guard isMirrorDestinationValid(destination) else {
			return []
		}

		let invalidSourceIDs = mirrorSourceIDsCreatingReferenceCycle(
			to: destination
		)
		return storage.identifiers.reduce(into: Set<ID>()) { sourceIDs, id in
			guard case .item = storage[id]?.value,
				  !invalidSourceIDs.contains(id) else {
				return
			}
			sourceIDs.insert(id)
		}
	}
}

// MARK: - MirrorStoring
extension MirrorStore: MirrorStoring {

	public func insertItems(
		from data: [any TreeNode<Container<Content, ID>>],
		to destination: Destination<ID>
	) throws(MirrorStoreError) {
		let newNodes = data.map {
			$0.map(type: Node<Container<Content, ID>>.self)
		}
		try insertNodes(newNodes, to: destination)
	}

	public func insert<T: TreeNode>(
		nodes: [T],
		to destination: Destination<ID>
	) throws(MirrorStoreError) where T.Value == Container<Content, ID> {
		let newNodes = nodes.map {
			$0.map(type: Node<Container<Content, ID>>.self)
		}
		try insertNodes(newNodes, to: destination)
	}

	public func deleteItems<S: Sequence>(_ ids: S) where S.Element == ID {
		ids.forEach { deleteItem($0) }
	}

	public func moveItems<S: Sequence>(
		_ ids: S,
		to destination: Destination<ID>
	) throws(MirrorStoreError) where S.Element == ID {
		var moved: [Node<Container<Content, ID>>] = []
		var movedIDs = Set<ID>()
		for id in ids {
			guard movedIDs.insert(id).inserted, let node = storage[id] else {
				continue
			}
			moved.append(node)
		}

		try validateDestination(destination)
		try validateMoving(moved, to: destination)

		let originalNodes = storage.nodes.map { $0.copy() }
		move(moved, to: destination)

		do {
			try validateStore()
		} catch {
			storage.nodes = originalNodes
			storage.resetCache()
			storage.updateCache(inserted: storage.nodes)
			throw error
		}
	}

	public func validateMove<S: Sequence>(
		_ ids: S,
		to destination: Destination<ID>
	) -> Bool where S.Element == ID {
		var moved: [Node<Container<Content, ID>>] = []
		var movedIDs = Set<ID>()
		for id in ids {
			guard movedIDs.insert(id).inserted, let node = storage[id] else {
				continue
			}
			moved.append(node)
		}

		do {
			try validateDestination(destination)
			try validateMoving(moved, to: destination)
		} catch {
			return false
		}

		let originalNodes = storage.nodes.map { $0.copy() }
		move(moved, to: destination)

		defer {
			storage.nodes = originalNodes
			storage.resetCache()
			storage.updateCache(inserted: storage.nodes)
		}

		do {
			try validateStore()
			return true
		} catch {
			return false
		}
	}

	public func set<T>(
		_ keyPath: WritableKeyPath<Content, T>,
		to value: T,
		for ids: [ID],
		includingDescendants: Bool
	) {
		var sourceIDs = [ID]()
		var visited = Set<ID>()

		for id in ids {
			guard let node = storage[id] else {
				continue
			}
			collectSourceIDs(
				from: node,
				includingDescendants: includingDescendants,
				into: &sourceIDs,
				visited: &visited
			)
		}

		for sourceID in sourceIDs {
			guard let sourceNode = storage[sourceID],
				  case let .item(id, content) = sourceNode.value else {
				continue
			}
			var updatedContent = content
			updatedContent[keyPath: keyPath] = value
			sourceNode.value = .item(id: id, content: updatedContent)
		}
	}

}

// MARK: - Insertion Helpers
private extension MirrorStore {

	func isMirrorDestinationValid(_ destination: Destination<ID>) -> Bool {
		switch destination {
		case .toRoot:
			return true
		case let .inRoot(atIndex: index):
			return (0...storage.nodes.count).contains(index)
		case let .onItem(with: id):
			guard case .item = storage[id]?.value else {
				return false
			}
			return true
		case let .inItem(with: id, atIndex: index):
			guard let target = storage[id], case .item = target.value else {
				return false
			}
			return (0...target.children.count).contains(index)
		}
	}

	func mirrorSourceIDsCreatingReferenceCycle(
		to destination: Destination<ID>
	) -> Set<ID> {
		guard let targetID = destination.id else {
			return []
		}

		let mirrorParentIDsByReference = mirrorParentIDsByReference()
		var invalidSourceIDs = Set<ID>()
		var pendingIDs = [targetID]
		while let id = pendingIDs.popLast() {
			guard invalidSourceIDs.insert(id).inserted,
				  let item = storage[id] else {
				continue
			}

			if let parentID = item.parent?.id {
				pendingIDs.append(parentID)
			}
			pendingIDs.append(contentsOf: mirrorParentIDsByReference[id, default: []])
		}
		return invalidSourceIDs
	}

	func mirrorParentIDsByReference() -> [ID: Set<ID>] {
		var parentIDsByReference: [ID: Set<ID>] = [:]

		for node in storage.nodes {
			node.traverse { node in
				guard case let .mirror(_, reference) = node.value,
					  let parentID = node.parent?.id else {
					return
				}
				parentIDsByReference[reference, default: []].insert(parentID)
			}
		}

		return parentIDsByReference
	}

	func referenceDependencies() -> [ID: Set<ID>] {
		var dependencies: [ID: Set<ID>] = [:]

		for node in storage.nodes {
			var itemAncestorIDs: [ID] = []
			node.traverse(
				enter: { node in
					switch node.value {
					case let .item(id, _):
						itemAncestorIDs.append(id)
					case let .mirror(_, reference):
						for ancestorID in itemAncestorIDs {
							dependencies[ancestorID, default: []].insert(reference)
						}
					}
				},
				leave: { node in
					if case .item = node.value {
						itemAncestorIDs.removeLast()
					}
				}
			)
		}

		return dependencies
	}

	func insertNodes(
		_ newNodes: [Node<Container<Content, ID>>],
		to destination: Destination<ID>
	) throws(MirrorStoreError) {
		try validateUniqueIdentifiers(in: newNodes)
		try validateDestination(destination)
		prepareIdentifiers(for: newNodes)

		insert(newNodes, to: destination)
		storage.updateCache(inserted: newNodes)

		do {
			try validateStore()
		} catch {
			remove(newNodes, from: destination)
			storage.updateCache(removed: newNodes)
			throw error
		}
	}

	func collectSourceIDs(
		from node: Node<Container<Content, ID>>,
		includingDescendants: Bool,
		into sourceIDs: inout [ID],
		visited: inout Set<ID>
	) {
		let sourceID = node.value.itemID
		guard let sourceNode = storage[sourceID], case .item = sourceNode.value else {
			return
		}
		guard visited.insert(sourceID).inserted else {
			return
		}
		sourceIDs.append(sourceID)

		guard includingDescendants else {
			return
		}
		for child in sourceNode.children {
			collectSourceIDs(
				from: child,
				includingDescendants: true,
				into: &sourceIDs,
				visited: &visited
			)
		}
	}

	func insert(
		_ nodes: [Node<Container<Content, ID>>],
		to destination: Destination<ID>
	) {
		switch destination {
		case .toRoot:
			storage.nodes.append(contentsOf: nodes)
		case let .inRoot(atIndex: index):
			storage.nodes.insert(contentsOf: nodes, at: index)
		case let .onItem(with: id):
			storage[id]?.appendItems(with: nodes)
		case let .inItem(with: id, atIndex: index):
			storage[id]?.insertItems(with: nodes, to: index)
		}
	}

	func prepareIdentifiers(for nodes: [Node<Container<Content, ID>>]) {
		var occupied = storage.identifiers
		var replacements: [ID: ID] = [:]

		for root in nodes {
			root.traverse { node in
				let originalID = node.id
				guard occupied.contains(originalID) else {
					occupied.insert(originalID)
					return
				}

				var replacement = ID.random()
				while occupied.contains(replacement) {
					replacement = ID.random()
				}
				node.value.id = replacement
				replacements[originalID] = replacement
				occupied.insert(replacement)
			}
		}

		guard !replacements.isEmpty else {
			return
		}

		for root in nodes {
			root.traverse { node in
				guard case let .mirror(id, reference) = node.value,
					  let replacement = replacements[reference] else {
					return
				}
				node.value = .mirror(id: id, reference: replacement)
			}
		}
	}

	func remove(
		_ nodes: [Node<Container<Content, ID>>],
		from destination: Destination<ID>
	) {
		let identifiers = Set(nodes.map(\.id))
		switch destination {
		case .toRoot, .inRoot:
			storage.nodes.removeAll { identifiers.contains($0.id) }
		case let .onItem(with: id), let .inItem(with: id, atIndex: _):
			storage[id]?.children.removeAll { identifiers.contains($0.id) }
		}
	}

	func deleteItem(_ id: ID) {
		guard let item = storage[id] else {
			return
		}

		var removedIDs = Set<ID>()
		item.traverse { node in
			removedIDs.insert(node.id)
		}

		var removedSourceIDs = Set<ID>()
		for removedID in removedIDs {
			if case .item = storage[removedID]?.value {
				removedSourceIDs.insert(removedID)
			}
		}

		for root in storage.nodes {
			root.traverse { node in
				guard case let .mirror(_, reference) = node.value,
					  removedSourceIDs.contains(reference) else {
					return
				}
				removedIDs.insert(node.id)
			}
		}

		let removedNodes = removedIDs.compactMap { storage[$0] }
		storage.updateCache(removed: removedNodes)
		removeNodes(with: removedIDs, from: &storage.nodes)

	}

	func removeNodes(
		with ids: Set<ID>,
		from nodes: inout [Node<Container<Content, ID>>]
	) {
		nodes.removeAll { ids.contains($0.id) }
		for node in nodes {
			var children = node.children
			removeNodes(with: ids, from: &children)
			node.children = children
		}
	}

	func move(
		_ nodes: [Node<Container<Content, ID>>],
		to destination: Destination<ID>
	) {
		let movedIDs = Set(nodes.map(\.id))
		let insertionIndex: Int?
		switch destination {
		case let .inRoot(atIndex: index):
			insertionIndex = adjustedIndex(index, in: storage.nodes, moving: movedIDs)
		case let .inItem(with: id, atIndex: index):
			insertionIndex = storage[id].map {
				adjustedIndex(index, in: $0.children, moving: movedIDs)
			}
		default:
			insertionIndex = nil
		}

		for node in nodes {
			if let parent = node.parent {
				parent.children.removeAll { movedIDs.contains($0.id) }
			} else {
				storage.nodes.removeAll { movedIDs.contains($0.id) }
			}
		}

		switch destination {
		case .toRoot:
			storage.nodes.append(contentsOf: nodes)
			nodes.forEach { $0.parent = nil }
		case .inRoot:
			storage.nodes.insert(contentsOf: nodes, at: insertionIndex ?? storage.nodes.count)
			nodes.forEach { $0.parent = nil }
		case let .onItem(with: id):
			storage[id]?.appendItems(with: nodes)
		case let .inItem(with: id, atIndex: _):
			if let target = storage[id] {
				target.insertItems(with: nodes, to: insertionIndex ?? target.children.count)
			}
		}
	}

	func adjustedIndex(
		_ index: Int,
		in siblings: [Node<Container<Content, ID>>],
		moving ids: Set<ID>
	) -> Int {
		let offset = siblings[..<index].reduce(into: 0) { result, node in
			if ids.contains(node.id) {
				result += 1
			}
		}
		return index - offset
	}
}

// MARK: - Validation
private extension MirrorStore {

	func validateStore() throws(MirrorStoreError) {
		try validateUniqueIdentifiers(in: storage.nodes)
		try validateReferences(in: storage.nodes)
		try validateReferenceCycles()
		try validateMirrorChildren(in: storage.nodes)
	}

	func validateDestination(_ destination: Destination<ID>) throws(MirrorStoreError) {
		switch destination {
		case .toRoot:
			return
		case let .inRoot(atIndex: index):
			guard (0...storage.nodes.count).contains(index) else {
				throw MirrorStoreError.invalidDestinationIndex
			}
		case let .onItem(with: id):
			guard storage[id] != nil else {
				throw MirrorStoreError.missingDestination
			}
		case let .inItem(with: id, atIndex: index):
			guard let target = storage[id] else {
				throw MirrorStoreError.missingDestination
			}
			guard (0...target.children.count).contains(index) else {
				throw MirrorStoreError.invalidDestinationIndex
			}
		}
	}

	func validateMoving(
		_ nodes: [Node<Container<Content, ID>>],
		to destination: Destination<ID>
	) throws(MirrorStoreError) {
		guard let targetID = destination.id else {
			return
		}
		for node in nodes where node.id == targetID || node.isAncestor(of: targetID) {
			throw MirrorStoreError.movingIntoDescendant
		}
	}

	func validateUniqueIdentifiers(
		in nodes: [Node<Container<Content, ID>>]
	) throws(MirrorStoreError) {
		var identifiers = Set<ID>()
		for node in nodes {
			try node.traverse(
				enter: { (node: Node<Container<Content, ID>>) throws(MirrorStoreError) in
					guard identifiers.insert(node.id).inserted else {
						throw MirrorStoreError.duplicateIdentifier
					}
				}
			)
		}
	}

	func validateReferences(
		in nodes: [Node<Container<Content, ID>>]
	) throws(MirrorStoreError) {
		for node in nodes {
			try node.traverse(
				enter: { (node: Node<Container<Content, ID>>) throws(MirrorStoreError) in
					guard case let .mirror(_, reference) = node.value else {
						return
					}
					guard let target = storage[reference] else {
						throw MirrorStoreError.missingReference
					}
					guard case .item = target.value else {
						throw MirrorStoreError.referenceIsMirror
					}
				}
			)
		}
	}

	func validateReferenceCycles() throws(MirrorStoreError) {
		let dependencies = referenceDependencies()

		var visited = Set<ID>()
		var visiting = Set<ID>()

		for start in dependencies.keys where !visited.contains(start) {
			var pending: [(id: ID, leaving: Bool)] = [(start, false)]

			while let visit = pending.popLast() {
				if visit.leaving {
					visiting.remove(visit.id)
					visited.insert(visit.id)
					continue
				}

				guard !visited.contains(visit.id) else {
					continue
				}
				guard visiting.insert(visit.id).inserted else {
					throw MirrorStoreError.referenceCycle
				}

				pending.append((visit.id, true))
				for dependency in dependencies[visit.id, default: []] {
					guard !visiting.contains(dependency) else {
						throw MirrorStoreError.referenceCycle
					}
					if !visited.contains(dependency) {
						pending.append((dependency, false))
					}
				}
			}
		}
	}

	func validateMirrorChildren(
		in nodes: [Node<Container<Content, ID>>]
	) throws(MirrorStoreError) {
		for node in nodes {
			try node.traverse(
				enter: { (node: Node<Container<Content, ID>>) throws(MirrorStoreError) in
					if case .mirror = node.value, !node.children.isEmpty {
						throw MirrorStoreError.mirrorHasChildren
					}
				}
			)
		}
	}

}

// MARK: - MirrorReading
extension MirrorStore: MirrorReading {

	public var identifiers: Set<ID> {
		storage.identifiers
	}

	public func parent(of id: ID) -> ID? {
		return storage[id]?.parent?.id
	}

	public func children(of parent: ID?) -> [ID] {
		guard let parent else {
			return storage.nodes.map(\.id)
		}
		return storage[parent]?.children.map(\.id) ?? []
	}

	public subscript(id: ID) -> Resolved<Content, ID>? {
		item(with: id)
	}
}

// MARK: - Helpers
private extension MirrorStore {

	func item(with id: ID) -> Resolved<Content, ID>? {
		guard let container = storage[id]?.value else {
			return nil
		}
		switch container {
		case let .item(_, content):
			return Resolved(id: id, content: content)
		case let .mirror(_, reference):
			guard case let .item(_, content) = storage[reference]?.value else {
				assertionFailure("Link to non-item")
				return nil
			}
			return Resolved(id: id, content: content, isMirror: true)
		}
	}
}

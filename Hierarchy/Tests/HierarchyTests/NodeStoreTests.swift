import Testing
@testable import Hierarchy

struct NodeStoreTests { }

// MARK: - Copying
extension NodeStoreTests {

	@Test func copyNode() async throws {
		let store = NodeStore(hierarchy: [NodeStoreTestFixtures.makeNode()])
		let original = store.nodes(type: NodeStoreTestNode.self)[0]

		try store.copy(ids: [original.id], to: .toRoot)

		let nodes = store.nodes(type: NodeStoreTestNode.self)
		let copy = nodes[1]

		#expect(nodes.count == 2)
		#expect(copy.value.title == original.value.title)
		#expect(copy.id != original.id)
		#expect(copy.parent == nil)
		#expect(nodes[0].id == original.id)
		#expect(nodes[1].id == copy.id)

		#expect(copy.children.count == original.children.count)
		#expect(copy.children[0].value.title == original.children[0].value.title)
		#expect(copy.children[0].id != original.children[0].id)
		#expect(copy.children[0].parent === copy)

		#expect(copy.children[0].children[0].value.title == original.children[0].children[0].value.title)
		#expect(copy.children[0].children[0].id != original.children[0].children[0].id)
		#expect(copy.children[0].children[0].parent === copy.children[0])
	}

	@Test func copyNodeThrowsMissingNodeForMissingDestination() async throws {
		let store = NodeStore(hierarchy: [NodeStoreTestFixtures.makeNode()])
		let original = store.nodes(type: NodeStoreTestNode.self)[0]

		do {
			try store.copy(ids: [original.id], to: .onItem(with: 404))
			Issue.record("Expected missing node error")
		} catch NodeStoreError.missingNode {
			let nodes = store.nodes(type: NodeStoreTestNode.self)
			#expect(nodes.count == 1)
			#expect(nodes[0].id == original.id)
		} catch {
			Issue.record("Expected missing node error")
		}
	}

	@Test func copiedDisjointSubtreesRemovesNestedRequestedNodes() async throws {
		let store = NodeStore(hierarchy: [NodeStoreTestFixtures.makeNode()])
		let root = store.nodes(type: NodeStoreTestNode.self)[0]
		let child = root.children[0]

		let copied = store.copiedDisjointSubtrees(with: [root.id, child.id])

		#expect(copied.count == 2)
		#expect(copied[0].id == root.id)
		#expect(copied[0].children.isEmpty)
		#expect(copied[1].id == child.id)
		#expect(copied[1].children.count == 1)
		#expect(root.children.count == 1)
	}
}

// MARK: - Matching
extension NodeStoreTests {

	@Test func allMatchChecksOnlyLeafNodes() async throws {
		let store = NodeStore(hierarchy: [NodeStoreTestFixtures.makeNode()])
		let root = store.nodes(type: NodeStoreTestNode.self)[0]
		let child = root.children[0]

		#expect(store.allMatch(id: root.id, keyPath: \.title, equalsTo: "grandchild"))
		#expect(store.allMatch(id: child.id, keyPath: \.title, equalsTo: "grandchild"))
		#expect(!store.allMatch(id: 404, keyPath: \.title, equalsTo: "grandchild"))
	}
}

// MARK: - Properties
extension NodeStoreTests {

	@Test func setPropertyUpdatesSelectedNodeOnly() async throws {
		let store = NodeStore(hierarchy: [NodeStoreTestFixtures.makeNode()])
		let root = store.nodes(type: NodeStoreTestNode.self)[0]
		let child = root.children[0]
		let grandchild = child.children[0]

		store.setProperty(\.title, to: "updated", for: [child.id])

		#expect(store[root.id]?.title == "root")
		#expect(store[child.id]?.title == "updated")
		#expect(store[grandchild.id]?.title == "grandchild")
	}

	@Test func setPropertyUpdatesSelectedNodeAndDescendants() async throws {
		let store = NodeStore(hierarchy: [NodeStoreTestFixtures.makeNode()])
		let root = store.nodes(type: NodeStoreTestNode.self)[0]
		let child = root.children[0]
		let grandchild = child.children[0]

		store.setProperty(\.title, to: "updated", for: [child.id], downstream: true)

		#expect(store[root.id]?.title == "root")
		#expect(store[child.id]?.title == "updated")
		#expect(store[grandchild.id]?.title == "updated")
	}
}

// MARK: - NodeReading
extension NodeStoreTests {

	@Test func identifiersReturnsAllNodeIdentifiers() async throws {
		// Arrange
		let store = NodeStore(hierarchy: [NodeStoreTestFixtures.makeNode()])

		// Act
		let result = store.identifiers

		// Assert
		#expect(result == Set([1, 2, 3]))
	}

	@Test func subscriptReturnsStoredValueOrNilForMissingNode() async throws {
		// Arrange
		let store = NodeStore(hierarchy: [NodeStoreTestFixtures.makeNode()])

		// Act
		let storedValue = store[2]
		let missingValue = store[404]

		// Assert
		#expect(storedValue == NodeStoreTestItem(id: 2, title: "child"))
		#expect(missingValue == nil)
	}

	@Test func parentReturnsParentIdentifierForNestedNode() async throws {
		// Arrange
		let store = NodeStore(hierarchy: [NodeStoreTestFixtures.makeNode()])
		let root = store.nodes(type: NodeStoreTestNode.self)[0]
		let child = root.children[0]
		let grandchild = child.children[0]

		// Act
		let rootParent = store.parent(of: root.id)
		let childParent = store.parent(of: child.id)
		let grandchildParent = store.parent(of: grandchild.id)

		// Assert
		#expect(rootParent == nil)
		#expect(childParent == root.id)
		#expect(grandchildParent == child.id)
	}

	@Test func descendantIDsIncludesRequestedNodesAndDescendants() async throws {
		// Arrange
		let store = NodeStore(hierarchy: [NodeStoreTestFixtures.makeNode()])
		let root = store.nodes(type: NodeStoreTestNode.self)[0]
		let child = root.children[0]
		let grandchild = child.children[0]

		// Act
		let result = store.descendantIDs(including: Set([child.id]))

		// Assert
		#expect(result == Set([child.id, grandchild.id]))
		#expect(!result.contains(root.id))
	}
}

// MARK: - Insertion
extension NodeStoreTests {

	@Test func insertRegeneratesIdentifierUntilItIsUnique() async throws {
		// Arrange
		NodeStoreCollisionIdentifier.generatedIdentifiers = [
			NodeStoreCollisionIdentifier(rawValue: 2),
			NodeStoreCollisionIdentifier(rawValue: 3)
		]
		let store = NodeStore(hierarchy: [
			Node(value: NodeStoreCollisionItem(id: .init(rawValue: 1))),
			Node(value: NodeStoreCollisionItem(id: .init(rawValue: 2)))
		])

		// Act
		try store.insert([
			NodeStoreCollisionItem(id: .init(rawValue: 1))
		], at: .toRoot)

		// Assert
		#expect(store.identifiers == Set([
			NodeStoreCollisionIdentifier(rawValue: 1),
			NodeStoreCollisionIdentifier(rawValue: 2),
			NodeStoreCollisionIdentifier(rawValue: 3)
		]))
	}

	@Test func insertAddsRootAndNestedItemsToCache() async throws {
		let store = NodeStore(hierarchy: [NodeStoreTestFixtures.makeNode()])
		let root = store.nodes(type: NodeStoreTestNode.self)[0]

		try store.insert([
			NodeStoreTestItem(id: 4, title: "inserted-root")
		], at: .toRoot)
		try store.insert([
			NodeStoreTestItem(id: 5, title: "inserted-child")
		], at: .inItem(with: root.id, atIndex: 0))

		let nodes = store.nodes(type: NodeStoreTestNode.self)
		#expect(nodes.map(\.id) == [1, 4])
		#expect(nodes[0].children.map(\.id) == [5, 2])
		#expect(store[4]?.title == "inserted-root")
		#expect(store[5]?.title == "inserted-child")
		#expect(store.parent(of: 5) == root.id)
	}

	@Test func insertThrowsMissingNodeForMissingDestination() async throws {
		let store = NodeStore(hierarchy: [NodeStoreTestFixtures.makeNode()])
		let item = NodeStoreTestItem(id: 4, title: "inserted-root")

		do {
			try store.insert([item], at: .onItem(with: 404))
			Issue.record("Expected missing node error")
		} catch NodeStoreError.missingNode {
			#expect(store.nodes(type: NodeStoreTestNode.self).map(\.id) == [1])
			#expect(store[4] == nil)
		} catch {
			Issue.record("Expected missing node error")
		}
	}

	@Test func insertThrowsMissingNodeForMissingIndexedDestination() async throws {
		let store = NodeStore(hierarchy: [NodeStoreTestFixtures.makeNode()])
		let item = NodeStoreTestItem(id: 4, title: "inserted-root")

		do {
			try store.insert([item], at: .inItem(with: 404, atIndex: 0))
			Issue.record("Expected missing node error")
		} catch NodeStoreError.missingNode {
			#expect(store.nodes(type: NodeStoreTestNode.self).map(\.id) == [1])
			#expect(store[4] == nil)
		} catch {
			Issue.record("Expected missing node error")
		}
	}
}

// MARK: - Deletion
extension NodeStoreTests {

	@Test func deleteItemsRemovesNodeAndDescendantsFromCache() async throws {
		let store = NodeStore(hierarchy: [NodeStoreTestFixtures.makeNode()])
		let root = store.nodes(type: NodeStoreTestNode.self)[0]
		let child = root.children[0]
		let grandchild = child.children[0]

		store.deleteItems(withIDs: [child.id])

		#expect(store.nodes(type: NodeStoreTestNode.self)[0].children.isEmpty)
		#expect(store[child.id] == nil)
		#expect(store[grandchild.id] == nil)
		#expect(store[root.id]?.title == "root")
	}
}

// MARK: - Moving
extension NodeStoreTests {

	@Test func canMoveItemsRejectsMovingNodeIntoDescendant() async throws {
		// Arrange
		let store = NodeStore(hierarchy: [NodeStoreTestFixtures.makeNode()])
		let root = store.nodes(type: NodeStoreTestNode.self)[0]
		let child = root.children[0]
		let grandchild = child.children[0]

		// Act
		let canMoveRootToGrandchild = store.canMoveItems(
			withIDs: [root.id],
			to: .onItem(with: grandchild.id)
		)
		let canMoveChildToGrandchild = store.canMoveItems(
			withIDs: [child.id],
			to: .inItem(with: grandchild.id, atIndex: 0)
		)
		let canMoveGrandchildToRoot = store.canMoveItems(
			withIDs: [grandchild.id],
			to: .onItem(with: root.id)
		)

		// Assert
		#expect(!canMoveRootToGrandchild)
		#expect(!canMoveChildToGrandchild)
		#expect(canMoveGrandchildToRoot)
	}

	@Test func moveItemsMovesNestedNodeToRoot() async throws {
		let store = NodeStore(hierarchy: [NodeStoreTestFixtures.makeNode()])
		let root = store.nodes(type: NodeStoreTestNode.self)[0]
		let child = root.children[0]
		let grandchild = child.children[0]

		try store.moveItems(withIDs: [child.id], to: .toRoot)

		let nodes = store.nodes(type: NodeStoreTestNode.self)
		#expect(nodes.map(\.id) == [root.id, child.id])
		#expect(nodes[0].children.isEmpty)
		#expect(nodes[1].parent == nil)
		#expect(nodes[1].children[0].id == grandchild.id)
		#expect(store.parent(of: grandchild.id) == child.id)
	}

	@Test func moveItemsThrowsMissingNodeForMissingDestination() async throws {
		let store = NodeStore(hierarchy: [NodeStoreTestFixtures.makeNode()])
		let root = store.nodes(type: NodeStoreTestNode.self)[0]
		let child = root.children[0]

		do {
			try store.moveItems(withIDs: [child.id], to: .onItem(with: 404))
			Issue.record("Expected missing node error")
		} catch NodeStoreError.missingNode {
			let nodes = store.nodes(type: NodeStoreTestNode.self)
			#expect(nodes.map(\.id) == [root.id])
			#expect(nodes[0].children.map(\.id) == [child.id])
			#expect(store.parent(of: child.id) == root.id)
		} catch {
			Issue.record("Expected missing node error")
		}
	}
}

private typealias NodeStoreTestNode = Node<NodeStoreTestItem>

private struct NodeStoreTestItem: Hashable {
	var id: Int
	var title: String
}

// MARK: - MutableIdentifiable
extension NodeStoreTestItem: MutableIdentifiable { }

// MARK: - Nested data structs
private struct NodeStoreCollisionItem: Hashable {
	var id: NodeStoreCollisionIdentifier
}

private struct NodeStoreCollisionIdentifier: Hashable {
	let rawValue: Int

	static var generatedIdentifiers: [NodeStoreCollisionIdentifier] = []
}

// MARK: - MutableIdentifiable
extension NodeStoreCollisionItem: MutableIdentifiable { }

// MARK: - RandomizableIdentifier
extension NodeStoreCollisionIdentifier: RandomizableIdentifier {

	static func random() -> NodeStoreCollisionIdentifier {
		return generatedIdentifiers.removeFirst()
	}
}

// MARK: - Test fixtures
private enum NodeStoreTestFixtures {

	static func makeNode() -> Node<NodeStoreTestItem> {
		return Node(
			value: NodeStoreTestItem(id: 1, title: "root"),
			children: [
				Node(
					value: NodeStoreTestItem(id: 2, title: "child"),
					children: [
						Node(value: NodeStoreTestItem(id: 3, title: "grandchild"))
					]
				)
			]
		)
	}
}

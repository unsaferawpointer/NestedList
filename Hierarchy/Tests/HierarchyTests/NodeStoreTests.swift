import Testing
@testable import Hierarchy

struct NodeStoreTests { }

// MARK: - Copying
extension NodeStoreTests {

	@Test func copyNode() async throws {
		let store = NodeStore(hierarchy: [NodeStoreTestFixtures.makeNode()])
		let original = store.nodes[0]

		try store.copy(ids: [original.id], to: .toRoot)

		let copy = store.nodes[1]

		#expect(store.nodes.count == 2)
		#expect(copy !== original)
		#expect(copy.value.title == original.value.title)
		#expect(copy.id != original.id)
		#expect(copy.parent == nil)
		#expect(store.nodes[0] === original)
		#expect(store.nodes[1] === copy)

		#expect(copy.children.count == original.children.count)
		#expect(copy.children[0] !== original.children[0])
		#expect(copy.children[0].value.title == original.children[0].value.title)
		#expect(copy.children[0].id != original.children[0].id)
		#expect(copy.children[0].parent === copy)

		#expect(copy.children[0].children[0] !== original.children[0].children[0])
		#expect(copy.children[0].children[0].value.title == original.children[0].children[0].value.title)
		#expect(copy.children[0].children[0].id != original.children[0].children[0].id)
		#expect(copy.children[0].children[0].parent === copy.children[0])
	}

	@Test func copyNodeThrowsMissingNodeForMissingDestination() async throws {
		let store = NodeStore(hierarchy: [NodeStoreTestFixtures.makeNode()])
		let original = store.nodes[0]

		do {
			try store.copy(ids: [original.id], to: .onItem(with: 404))
			Issue.record("Expected missing node error")
		} catch NodeStoreError.missingNode {
			#expect(store.nodes.count == 1)
			#expect(store.nodes[0] === original)
		} catch {
			Issue.record("Expected missing node error")
		}
	}

	@Test func copiedDisjointSubtreesRemovesNestedRequestedNodes() async throws {
		let store = NodeStore(hierarchy: [NodeStoreTestFixtures.makeNode()])
		let root = store.nodes[0]
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

// MARK: - Matching and counting
extension NodeStoreTests {

	@Test func allMatchChecksOnlyLeafNodes() async throws {
		let store = NodeStore(hierarchy: [NodeStoreTestFixtures.makeNode()])
		let root = store.nodes[0]
		let child = root.children[0]

		#expect(store.allMatch(\.title, equalsTo: "grandchild"))
		#expect(store.allMatch(id: root.id, keyPath: \.title, equalsTo: "grandchild"))
		#expect(store.allMatch(id: child.id, keyPath: \.title, equalsTo: "grandchild"))
		#expect(!store.allMatch(\.title, equalsTo: "child"))
		#expect(!store.allMatch(id: 404, keyPath: \.title, equalsTo: "grandchild"))
	}

	@Test func countReturnsLeafNodeCount() async throws {
		let store = NodeStore(hierarchy: [NodeStoreTestFixtures.makeNode()])

		#expect(store.count == 1)
		#expect(store.count(where: \.title, equalsTo: "grandchild") == 1)
		#expect(store.count(where: \.title, equalsTo: "child") == 0)
	}
}

// MARK: - Properties
extension NodeStoreTests {

	@Test func setPropertyUpdatesSelectedNodeOnly() async throws {
		let store = NodeStore(hierarchy: [NodeStoreTestFixtures.makeNode()])
		let root = store.nodes[0]
		let child = root.children[0]
		let grandchild = child.children[0]

		store.setProperty(\.title, to: "updated", for: [child.id])

		#expect(root.value.title == "root")
		#expect(child.value.title == "updated")
		#expect(grandchild.value.title == "grandchild")
	}

	@Test func setPropertyUpdatesSelectedNodeAndDescendants() async throws {
		let store = NodeStore(hierarchy: [NodeStoreTestFixtures.makeNode()])
		let root = store.nodes[0]
		let child = root.children[0]
		let grandchild = child.children[0]

		store.setProperty(\.title, to: "updated", for: [child.id], downstream: true)

		#expect(root.value.title == "root")
		#expect(child.value.title == "updated")
		#expect(grandchild.value.title == "updated")
	}
}

// MARK: - Parent lookup
extension NodeStoreTests {

	@Test func parentReturnsParentValueForNestedNode() async throws {
		let store = NodeStore(hierarchy: [NodeStoreTestFixtures.makeNode()])
		let root = store.nodes[0]
		let child = root.children[0]
		let grandchild = child.children[0]

		#expect(store.parent(for: nil) == nil)
		#expect(store.parent(for: root.id) == nil)
		#expect(store.parent(for: child.id)?.id == root.id)
		#expect(store.parent(for: grandchild.id)?.id == child.id)
	}
}

// MARK: - Insertion
extension NodeStoreTests {

	@Test func insertItemsAddsRootAndNestedItemsToCache() async throws {
		let store = NodeStore(hierarchy: [NodeStoreTestFixtures.makeNode()])
		let root = store.nodes[0]

		try store.insertItems(with: [
			NodeStoreTestItem(id: 4, title: "inserted-root")
		], to: .toRoot)
		try store.insertItems(with: [
			NodeStoreTestItem(id: 5, title: "inserted-child")
		], to: .inItem(with: root.id, atIndex: 0))

		#expect(store.nodes.map(\.id) == [1, 4])
		#expect(root.children.map(\.id) == [5, 2])
		#expect(store[4]?.title == "inserted-root")
		#expect(store[5]?.title == "inserted-child")
		#expect(store.parent(for: 5)?.id == root.id)
	}

	@Test func insertItemsThrowsMissingNodeForMissingDestination() async throws {
		let store = NodeStore(hierarchy: [NodeStoreTestFixtures.makeNode()])
		let item = NodeStoreTestItem(id: 4, title: "inserted-root")

		do {
			try store.insertItems(with: [item], to: .onItem(with: 404))
			Issue.record("Expected missing node error")
		} catch NodeStoreError.missingNode {
			#expect(store.nodes.map(\.id) == [1])
			#expect(store[4] == nil)
		} catch {
			Issue.record("Expected missing node error")
		}
	}

	@Test func insertItemsThrowsMissingNodeForMissingIndexedDestination() async throws {
		let store = NodeStore(hierarchy: [NodeStoreTestFixtures.makeNode()])
		let item = NodeStoreTestItem(id: 4, title: "inserted-root")

		do {
			try store.insertItems(with: [item], to: .inItem(with: 404, atIndex: 0))
			Issue.record("Expected missing node error")
		} catch NodeStoreError.missingNode {
			#expect(store.nodes.map(\.id) == [1])
			#expect(store[4] == nil)
		} catch {
			Issue.record("Expected missing node error")
		}
	}
}

// MARK: - Deletion
extension NodeStoreTests {

	@Test func deleteItemRemovesNodeAndDescendantsFromCache() async throws {
		let store = NodeStore(hierarchy: [NodeStoreTestFixtures.makeNode()])
		let root = store.nodes[0]
		let child = root.children[0]
		let grandchild = child.children[0]

		store.deleteItem(child.id)

		#expect(root.children.isEmpty)
		#expect(store[child.id] == nil)
		#expect(store[grandchild.id] == nil)
		#expect(store[root.id]?.title == "root")
	}
}

// MARK: - Moving
extension NodeStoreTests {

	@Test func invalidTargetsIncludesMovedNodesAndDescendants() async throws {
		let store = NodeStore(hierarchy: [NodeStoreTestFixtures.makeNode()])
		let root = store.nodes[0]
		let child = root.children[0]
		let grandchild = child.children[0]

		let result = store.invalidTargets(movingItems: [child.id])

		#expect(result == Set([child.id, grandchild.id]))
		#expect(!result.contains(root.id))
	}

	@Test func validateMovingRejectsMovingNodeIntoDescendant() async throws {
		let store = NodeStore(hierarchy: [NodeStoreTestFixtures.makeNode()])
		let root = store.nodes[0]
		let child = root.children[0]
		let grandchild = child.children[0]

		#expect(!store.validateMoving([root.id], to: .onItem(with: grandchild.id)))
		#expect(!store.validateMoving([child.id], to: .inItem(with: grandchild.id, atIndex: 0)))
		#expect(store.validateMoving([grandchild.id], to: .onItem(with: root.id)))
	}

	@Test func moveItemsMovesNestedNodeToRoot() async throws {
		let store = NodeStore(hierarchy: [NodeStoreTestFixtures.makeNode()])
		let root = store.nodes[0]
		let child = root.children[0]
		let grandchild = child.children[0]

		try store.moveItems(with: [child.id], to: .toRoot)

		#expect(store.nodes.map(\.id) == [root.id, child.id])
		#expect(root.children.isEmpty)
		#expect(child.parent == nil)
		#expect(child.children[0] === grandchild)
		#expect(store.parent(for: grandchild.id)?.id == child.id)
	}

	@Test func moveItemsThrowsMissingNodeForMissingDestination() async throws {
		let store = NodeStore(hierarchy: [NodeStoreTestFixtures.makeNode()])
		let root = store.nodes[0]
		let child = root.children[0]

		do {
			try store.moveItems(with: [child.id], to: .onItem(with: 404))
			Issue.record("Expected missing node error")
		} catch NodeStoreError.missingNode {
			#expect(store.nodes.map(\.id) == [root.id])
			#expect(root.children.map(\.id) == [child.id])
			#expect(child.parent === root)
		} catch {
			Issue.record("Expected missing node error")
		}
	}
}

private struct NodeStoreTestItem: Hashable {
	var id: Int
	var title: String
}

// MARK: - MutableIdentifiable
extension NodeStoreTestItem: MutableIdentifiable { }

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

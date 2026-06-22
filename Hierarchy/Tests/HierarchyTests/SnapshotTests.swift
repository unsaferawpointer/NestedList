import Testing
@testable import Hierarchy

@Test func snapshotBuildsHierarchyAndIndexes() async throws {
	let snapshot = Snapshot<TestItem>(TestFixtures.nodes)

	#expect(snapshot.root == ["root-a", "root-b"])
	#expect(snapshot.identifiers == Set(["root-a", "child-a", "grandchild-a", "grandchild-b", "child-b", "root-b", "child-c"]))
	#expect(snapshot.nodeIdentifiers == Set(["root-a", "child-a", "root-b"]))

	#expect(snapshot.children(of: "root-a").map(\.id) == ["child-a", "child-b"])
	#expect(snapshot.children(of: "child-a").map(\.id) == ["grandchild-a", "grandchild-b"])
	#expect(snapshot.children(of: "root-b").map(\.id) == ["child-c"])

	#expect(snapshot[0].id == "root-a")
	#expect(snapshot[1].id == "child-a")
	#expect(snapshot[2].id == "grandchild-a")
	#expect(snapshot[3].id == "grandchild-b")
	#expect(snapshot[4].id == "child-b")
	#expect(snapshot[5].id == "root-b")
	#expect(snapshot[6].id == "child-c")

	#expect(snapshot.level(for: "root-a") == 0)
	#expect(snapshot.level(for: "child-a") == 1)
	#expect(snapshot.level(for: "grandchild-a") == 2)
	#expect(snapshot.level(for: "child-c") == 1)

	#expect(snapshot.localIndex(for: "root-a") == 0)
	#expect(snapshot.localIndex(for: "root-b") == 1)
	#expect(snapshot.localIndex(for: "child-a") == 0)
	#expect(snapshot.localIndex(for: "child-b") == 1)
	#expect(snapshot.localIndex(for: "grandchild-b") == 1)

	#expect(snapshot.globalIndex(for: "root-a") == 0)
	#expect(snapshot.globalIndex(for: "child-a") == 1)
	#expect(snapshot.globalIndex(for: "grandchild-a") == 2)
	#expect(snapshot.globalIndex(for: "grandchild-b") == 3)
	#expect(snapshot.globalIndex(for: "child-b") == 4)
	#expect(snapshot.globalIndex(for: "root-b") == 5)
	#expect(snapshot.globalIndex(for: "child-c") == 6)

	#expect(snapshot.parent(for: "root-a") == nil)
	#expect(snapshot.parent(for: "child-a")?.id == "root-a")
	#expect(snapshot.parent(for: "grandchild-a")?.id == "child-a")
	#expect(snapshot.isLeaf(id: "child-b"))
	#expect(!snapshot.isLeaf(id: "child-a"))
}

@Test func snapshotWithRootNilReturnsOriginalRoot() async throws {
	let snapshot = Snapshot<TestItem>(TestFixtures.nodes)
	let result = snapshot.withRoot(parent: nil)

	#expect(result.root == ["root-a", "root-b"])
	#expect(result.identifiers == snapshot.identifiers)
	#expect(result.nodeIdentifiers == snapshot.nodeIdentifiers)
	#expect(result.children(of: "root-a").map(\.id) == ["child-a", "child-b"])
	#expect(result.globalIndex(for: "child-c") == 6)
}

@Test func snapshotWithRootPromotesParentChildrenAndRenormalizesTree() async throws {
	let snapshot = Snapshot<TestItem>(TestFixtures.nodes)
	let result = snapshot.withRoot(parent: "root-a")

	#expect(result.root == ["child-a", "child-b"])
	#expect(result.identifiers == Set(["child-a", "grandchild-a", "grandchild-b", "child-b"]))
	#expect(result.nodeIdentifiers == Set(["child-a"]))
	#expect(result.children(of: "child-a").map(\.id) == ["grandchild-a", "grandchild-b"])

	#expect(result[0].id == "child-a")
	#expect(result[1].id == "grandchild-a")
	#expect(result[2].id == "grandchild-b")
	#expect(result[3].id == "child-b")

	#expect(result.parent(for: "child-a") == nil)
	#expect(result.parent(for: "child-b") == nil)
	#expect(result.parent(for: "grandchild-a")?.id == "child-a")

	#expect(result.level(for: "child-a") == 0)
	#expect(result.level(for: "child-b") == 0)
	#expect(result.level(for: "grandchild-a") == 1)

	#expect(result.localIndex(for: "child-a") == 0)
	#expect(result.localIndex(for: "child-b") == 1)
	#expect(result.localIndex(for: "grandchild-b") == 1)

	#expect(result.globalIndex(for: "child-a") == 0)
	#expect(result.globalIndex(for: "grandchild-a") == 1)
	#expect(result.globalIndex(for: "grandchild-b") == 2)
	#expect(result.globalIndex(for: "child-b") == 3)
}

@Test func snapshotWithRootForLeafReturnsEmptySnapshot() async throws {
	let snapshot = Snapshot<TestItem>(TestFixtures.nodes)
	let result = snapshot.withRoot(parent: "child-b")

	#expect(result.root.isEmpty)
	#expect(result.identifiers.isEmpty)
	#expect(result.nodeIdentifiers.isEmpty)
	#expect(result.numberOfRootItems() == 0)
}

@Test func snapshotRemovedIdsRemovesRootNodeWithDescendants() async throws {
	let snapshot = Snapshot<TestItem>(TestFixtures.nodes)
	let result = snapshot.removed(ids: ["root-a"])

	#expect(result.root == ["root-b"])
	#expect(result.identifiers == Set(["root-b", "child-c"]))
	#expect(result.nodeIdentifiers == Set(["root-b"]))
	#expect(result.children(of: "root-b").map(\.id) == ["child-c"])
	#expect(result.parent(for: "root-b") == nil)
	#expect(result.parent(for: "child-c")?.id == "root-b")
	#expect(result.globalIndex(for: "root-b") == 0)
	#expect(result.globalIndex(for: "child-c") == 1)
}

@Test func snapshotRemovedIdsRemovesNestedNodeWithDescendants() async throws {
	let snapshot = Snapshot<TestItem>(TestFixtures.nodes)
	let result = snapshot.removed(ids: ["child-a"])

	#expect(result.root == ["root-a", "root-b"])
	#expect(result.identifiers == Set(["root-a", "child-b", "root-b", "child-c"]))
	#expect(result.nodeIdentifiers == Set(["root-a", "root-b"]))
	#expect(result.children(of: "root-a").map(\.id) == ["child-b"])
	#expect(result.children(of: "root-b").map(\.id) == ["child-c"])
	#expect(result.parent(for: "child-b")?.id == "root-a")
	#expect(result.localIndex(for: "child-b") == 0)
	#expect(result.globalIndex(for: "child-b") == 1)
	#expect(result.globalIndex(for: "root-b") == 2)
	#expect(result.globalIndex(for: "child-c") == 3)
}

@Test func snapshotRemovedIdsIgnoresUnknownIds() async throws {
	let snapshot = Snapshot<TestItem>(TestFixtures.nodes)
	let result = snapshot.removed(ids: ["missing"])

	#expect(result.root == snapshot.root)
	#expect(result.identifiers == snapshot.identifiers)
	#expect(result.nodeIdentifiers == snapshot.nodeIdentifiers)
	#expect(result.children(of: "root-a").map(\.id) == ["child-a", "child-b"])
	#expect(result.children(of: "child-a").map(\.id) == ["grandchild-a", "grandchild-b"])
	#expect(result.globalIndex(for: "child-c") == 6)
}

@Test func snapshotInsertedModelsInsertsIntoRootAndRenormalizesTree() async throws {
	let snapshot = Snapshot<TestItem>(TestFixtures.nodes)
	let result = snapshot.inserted(
		models: [
			TestItem(id: "root-c"),
			TestItem(id: "root-d")
		],
		to: .inRoot(atIndex: 1)
	)

	#expect(result.root == ["root-a", "root-c", "root-d", "root-b"])
	#expect(result.identifiers == Set(["root-a", "child-a", "grandchild-a", "grandchild-b", "child-b", "root-c", "root-d", "root-b", "child-c"]))
	#expect(result.parent(for: "root-c") == nil)
	#expect(result.parent(for: "root-d") == nil)
	#expect(result.level(for: "root-c") == 0)
	#expect(result.localIndex(for: "root-c") == 1)
	#expect(result.localIndex(for: "root-d") == 2)
	#expect(result.globalIndex(for: "root-c") == 5)
	#expect(result.globalIndex(for: "root-d") == 6)
	#expect(result.globalIndex(for: "root-b") == 7)
	#expect(result.globalIndex(for: "child-c") == 8)
}

@Test func snapshotInsertedModelsInsertsIntoItemAndRenormalizesTree() async throws {
	let snapshot = Snapshot<TestItem>(TestFixtures.nodes)
	let result = snapshot.inserted(
		models: [
			TestItem(id: "grandchild-c"),
			TestItem(id: "grandchild-d")
		],
		to: .inItem(with: "child-a", atIndex: 1)
	)

	#expect(result.root == ["root-a", "root-b"])
	#expect(result.children(of: "child-a").map(\.id) == ["grandchild-a", "grandchild-c", "grandchild-d", "grandchild-b"])
	#expect(result.identifiers == Set(["root-a", "child-a", "grandchild-a", "grandchild-c", "grandchild-d", "grandchild-b", "child-b", "root-b", "child-c"]))
	#expect(result.parent(for: "grandchild-c")?.id == "child-a")
	#expect(result.parent(for: "grandchild-d")?.id == "child-a")
	#expect(result.level(for: "grandchild-c") == 2)
	#expect(result.localIndex(for: "grandchild-c") == 1)
	#expect(result.localIndex(for: "grandchild-d") == 2)
	#expect(result.globalIndex(for: "grandchild-c") == 3)
	#expect(result.globalIndex(for: "grandchild-d") == 4)
	#expect(result.globalIndex(for: "grandchild-b") == 5)
}


private struct TestItem {
	var id: String
}

// MARK: - IdentifiableValue
extension TestItem: IdentifiableValue {

	mutating func generateId() { }
}

// MARK: - Test fixtures
private enum TestFixtures {

	static let nodes: [Node<TestItem>] = [
		Node(
			value: TestItem(id: "root-a"),
			children: [
				Node(
					value: TestItem(id: "child-a"),
					children: [
						Node(value: TestItem(id: "grandchild-a")),
						Node(value: TestItem(id: "grandchild-b"))
					]
				),
				Node(value: TestItem(id: "child-b"))
			]
		),
		Node(
			value: TestItem(id: "root-b"),
			children: [
				Node(value: TestItem(id: "child-c"))
			]
		)
	]
}

import Testing
@testable import Hierarchy

struct NodeReadingTests { }

// MARK: - Snapshot Support
extension NodeReadingTests {

	@Test
	func snapshotBuildsCurrentHierarchy() {
		// Arrange
		let storage = NodeStorageMock<TestItem<Int>>()
		storage.stubs.items = [
			1: TestItem(id: 1, title: "root"),
			2: TestItem(id: 2, title: "child")
		]
		storage.stubs.rootIDs = [1]
		storage.stubs.children = [1: [2]]

		// Act
		let snapshot = storage.snapshot()

		// Assert
		#expect(snapshot.root == [1])
		#expect(snapshot.hierarchy[1] == [2])
		#expect(snapshot.count == 2)
	}
}

// MARK: - Matching
extension NodeReadingTests {

	@Test
	func allMatchChecksOnlyLeafNodes() {
		// Arrange
		let storage = NodeStorageMock<TestItem<Int>>()
		storage.stubs.items = [
			1: TestItem(id: 1, title: "root"),
			2: TestItem(id: 2, title: "child"),
			3: TestItem(id: 3, title: "leaf"),
			4: TestItem(id: 4, title: "leaf")
		]
		storage.stubs.children = [
			1: [2, 4],
			2: [3]
		]

		// Act
		let rootMatches = storage.allMatch(id: 1, keyPath: \.title, equalsTo: "leaf")
		let subtreeMatches = storage.allMatch(id: 2, keyPath: \.title, equalsTo: "leaf")
		let rootDoesNotMatch = storage.allMatch(id: 1, keyPath: \.title, equalsTo: "other")
		let missingNodeMatches = storage.allMatch(id: 404, keyPath: \.title, equalsTo: "leaf")

		// Assert
		#expect(rootMatches)
		#expect(subtreeMatches)
		#expect(!rootDoesNotMatch)
		#expect(!missingNodeMatches)
	}
}

// MARK: - Tree nodes
extension NodeReadingTests {

	@Test
	func nodeReconstructsSubtree() throws {
		// Arrange
		let storage = NodeStorageMock<TestItem<Int>>()
		storage.stubs.items = [
			1: TestItem(id: 1, title: "root"),
			2: TestItem(id: 2, title: "child"),
			3: TestItem(id: 3, title: "grandchild")
		]
		storage.stubs.children = [
			1: [2],
			2: [3]
		]

		// Act
		let node = try #require(storage.node(with: 2, type: NodeReadingTestNode.self))
		let missingNode = storage.node(with: 404, type: NodeReadingTestNode.self)

		// Assert
		#expect(node.id == 2)
		#expect(node.children.map(\.id) == [3])
		#expect(missingNode == nil)
	}

	@Test
	func nodesReconstructsHierarchyInStorageOrder() {
		// Arrange
		let storage = NodeStorageMock<TestItem<Int>>()
		storage.stubs.items = [
			1: TestItem(id: 1, title: "first-root"),
			2: TestItem(id: 2, title: "child"),
			3: TestItem(id: 3, title: "grandchild"),
			4: TestItem(id: 4, title: "second-root")
		]
		storage.stubs.rootIDs = [1, 4]
		storage.stubs.children = [
			1: [2],
			2: [3]
		]

		// Act
		let nodes = storage.nodes(type: NodeReadingTestNode.self)

		// Assert
		#expect(nodes.map(\.id) == [1, 4])
		#expect(nodes[0].children.map(\.id) == [2])
		#expect(nodes[0].children[0].children.map(\.id) == [3])
		#expect(nodes[1].children.isEmpty)
	}
}

private typealias NodeReadingTestNode = Node<TestItem<Int>>

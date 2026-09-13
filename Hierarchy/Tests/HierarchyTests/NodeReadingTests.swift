import Testing
@testable import Hierarchy

struct NodeReadingTests { }

// MARK: - Tree nodes
extension NodeReadingTests {

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

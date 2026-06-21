import Testing
@testable import Hierarchy

@Test func nodeCopyCreatesNewTreeWithDescendants() async throws {

	let original = NodeTestFixtures.node
	let copy = original.copy()

	#expect(copy.id == original.id)
	#expect(copy !== original)
	#expect(copy.parent == nil)
	#expect(copy.children.count == original.children.count)
	#expect(copy.children[0] !== original.children[0])
	#expect(copy.children[0].parent === copy)
	#expect(copy.children[0].children[0] !== original.children[0].children[0])
	#expect(copy.children[0].children[0].parent === copy.children[0])
}

private struct NodeTestItem {
	let id: String
}

// MARK: - Identifiable
extension NodeTestItem: Identifiable { }

// MARK: - Test fixtures
private enum NodeTestFixtures {

	static let node = Node(
		value: NodeTestItem(id: "root"),
		children: [
			Node(
				value: NodeTestItem(id: "child"),
				children: [
					Node(value: NodeTestItem(id: "grandchild"))
				]
			)
		]
	)
}

import Testing
@testable import Hierarchy

@Test func copyNode() async throws {
	let store = NodeStore(hierarchy: [NodeStoreTestFixtures.makeNode()])
	let original = store.nodes[0]

	store.copy(ids: [original.id], to: .toRoot)

	let copy = store.nodes[1]

	#expect(store.nodes.count == 2)
	#expect(copy !== original)
	#expect(copy.value.title == original.value.title)
	#expect(copy.id != original.id)
	#expect(copy.parent == nil)
	#expect(store.node(with: original.id) === original)
	#expect(store.node(with: copy.id) === copy)

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

private struct NodeStoreTestItem: Hashable {
	var id: Int
	let title: String
}

// MARK: - IdentifiableValue
extension NodeStoreTestItem: IdentifiableValue {

	mutating func generateId() {
		id += 100
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

import Testing
@testable import Hierarchy

struct TreeNodeTests { }

// MARK: - TreeNode mapping
extension TreeNodeTests {

	@Test
	func mapTransformsValuesAndPreservesHierarchy() {
		// Arrange
		let node = Node(
			value: TestItem(id: 0, title: "root"),
			children: [
				Node(
					value: TestItem(id: 1, title: "child"),
					children: [Node(value: TestItem(id: 2, title: "grandchild"))]
				),
				Node(value: TestItem(id: 3, title: "sibling"))
			]
		)

		// Act
		let mapped: Node<MappedItem> = node.map {
			MappedItem(id: $0.id, title: $0.title.uppercased())
		}

		// Assert
		#expect(mapped == Node(
			value: MappedItem(id: 0, title: "ROOT"),
			children: [
				Node(
					value: MappedItem(id: 1, title: "CHILD"),
					children: [Node(value: MappedItem(id: 2, title: "GRANDCHILD"))]
				),
				Node(value: MappedItem(id: 3, title: "SIBLING"))
			]
		))
	}
}

// MARK: - Nested data structs
private extension TreeNodeTests {

	struct MappedItem: Identifiable, Equatable {
		let id: Int
		let title: String
	}
}

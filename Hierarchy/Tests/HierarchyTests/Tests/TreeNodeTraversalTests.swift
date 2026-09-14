import Testing
@testable import Hierarchy

struct TreeNodeTraversalTests { }

// MARK: - Traversal order
extension TreeNodeTraversalTests {

	@Test
	func traverseEntersAndLeavesSingleNode() {
		// Arrange
		let node = TestNode(value: TestItem(id: 0, title: "root"))
		var events: [Event] = []

		// Act
		node.traverse(
			enter: { events.append(.enter($0.id)) },
			leave: { events.append(.leave($0.id)) }
		)

		// Assert
		#expect(events == [.enter(0), .leave(0)])
	}

	@Test
	func traversePreservesChildOrderAndLeavesAfterDescendants() {
		// Arrange
		let node = Self.makeTree()
		var events: [Event] = []

		// Act
		node.traverse(
			enter: { events.append(.enter($0.id)) },
			leave: { events.append(.leave($0.id)) }
		)

		// Assert
		#expect(events == [
			.enter(0),
			.enter(1),
			.enter(2), .leave(2),
			.enter(3),
			.enter(4), .leave(4),
			.leave(3),
			.leave(1),
			.enter(5), .leave(5),
			.leave(0)
		])
	}

	@Test
	func traverseSupportsOmittingLeaveHandler() {
		// Arrange
		let node = Self.makeTree()
		var visitedIDs: [Int] = []

		// Act
		node.traverse(
			enter: {
				visitedIDs.append($0.id)
			}
		)

		// Assert
		#expect(visitedIDs == [0, 1, 2, 3, 4, 5])
	}
}

// MARK: - Error propagation
extension TreeNodeTraversalTests {

	@Test
	func traverseStopsWhenEnteringRootThrows() {
		// Arrange
		let node = Self.makeTree()
		var events: [Event] = []
		var receivedError: TraversalError?

		// Act
		do {
			try node.traverse(
				enter: { node throws(TraversalError) in
					events.append(.enter(node.id))
					throw .rejected(node.id)
				},
				leave: { events.append(.leave($0.id)) }
			)
		} catch {
			receivedError = error
		}

		// Assert
		#expect(receivedError == .rejected(0))
		#expect(events == [.enter(0)])
	}

	@Test
	func traverseStopsWithoutCallingPendingLeaveHandlersWhenDescendantThrows() {
		// Arrange
		let node = Self.makeTree()
		var events: [Event] = []
		var receivedError: TraversalError?

		// Act
		do {
			try node.traverse(
				enter: { node throws(TraversalError) in
					events.append(.enter(node.id))
					if node.id == 3 {
						throw .rejected(node.id)
					}
				},
				leave: { events.append(.leave($0.id)) }
			)
		} catch {
			receivedError = error
		}

		// Assert
		#expect(receivedError == .rejected(3))
		#expect(events == [.enter(0), .enter(1), .enter(2), .leave(2), .enter(3)])
	}
}

// MARK: - Nested data structs
private extension TreeNodeTraversalTests {

	typealias TestNode = Node<TestItem<Int>>

	enum Event: Equatable {
		case enter(Int)
		case leave(Int)
	}

	enum TraversalError: Error, Equatable {
		case rejected(Int)
	}

	static func makeTree() -> TestNode {
		TestNode(
			value: TestItem(id: 0, title: "root"),
			children: [
				TestNode(
					value: TestItem(id: 1, title: "first child"),
					children: [
						TestNode(value: TestItem(id: 2, title: "first grandchild")),
						TestNode(
							value: TestItem(id: 3, title: "second grandchild"),
							children: [TestNode(value: TestItem(id: 4, title: "great-grandchild"))]
						)
					]
				),
				TestNode(value: TestItem(id: 5, title: "second child"))
			]
		)
	}
}

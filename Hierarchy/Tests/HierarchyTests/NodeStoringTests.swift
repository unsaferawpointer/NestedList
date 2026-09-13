import Testing
@testable import Hierarchy

struct NodeStoringTests { }

// MARK: - Insertion
extension NodeStoringTests {

	@Test
	func insertWrapsValuesInLeafNodes() throws {
		// Arrange
		let storage = NodeStorageMock<TestItem<Int>>()
		let items = [
			TestItem(id: 1),
			TestItem(id: 2)
		]

		// Act
		try storage.insert(items, at: .onItem(with: 3))

		// Assert
		#expect(storage.invocations == [
			.insertItems(
				items: items,
				childrenCounts: [0, 0],
				destination: .onItem(with: 3)
			)
		])
	}
}

// MARK: - Moving
extension NodeStoringTests {

	@Test
	func canMoveItemsRejectsMovingNodeIntoItsDescendant() {
		// Arrange
		let storage = NodeStorageMock<TestItem<Int>>()
		storage.stubs.items = [
			1: TestItem(id: 1),
			2: TestItem(id: 2),
			3: TestItem(id: 3)
		]
		storage.stubs.parents = [
			2: 1,
			3: 2
		]

		// Act
		let canMoveRootToGrandchild = storage.canMoveItems([1], to: .onItem(with: 3))
		let canMoveChildToGrandchild = storage.canMoveItems([2], to: .inItem(with: 3, atIndex: 0))
		let canMoveGrandchildToRoot = storage.canMoveItems([3], to: .onItem(with: 1))
		let canMoveToRoot = storage.canMoveItems([1], to: .toRoot)
		let canMoveToMissingNode = storage.canMoveItems([1], to: .onItem(with: 404))

		// Assert
		#expect(!canMoveRootToGrandchild)
		#expect(!canMoveChildToGrandchild)
		#expect(canMoveGrandchildToRoot)
		#expect(canMoveToRoot)
		#expect(canMoveToMissingNode)
	}

	@Test
	func moveToEndMovesNodesWithinTheirCurrentContainers() throws {
		// Arrange
		let storage = NodeStorageMock<TestItem<Int>>()
		storage.stubs.items = [
			1: TestItem(id: 1),
			2: TestItem(id: 2),
			3: TestItem(id: 3)
		]
		storage.stubs.parents = [
			2: 10,
			3: 10
		]

		// Act
		try storage.moveToEnd([1, 2, 3, 404])

		// Assert
		#expect(storage.invocations.contains(
			.moveItems(ids: [1], destination: .toRoot)
		))
		#expect(storage.invocations.contains(
			.moveItems(ids: [2, 3], destination: .onItem(with: 10))
		))
		#expect(!storage.invocations.contains { action in
			guard case let .moveItems(ids, _) = action else {
				return false
			}
			return ids.contains(404)
		})
	}

	@Test
	func movementValidationChecksSiblingBoundaries() {
		// Arrange
		let storage = makeStorage()

		// Act
		let canMoveFirstForward = storage.validateMovingForward(1)
		let canMoveLastForward = storage.validateMovingForward(3)
		let canMoveFirstBackward = storage.validateMovingBackward(1)
		let canMoveLastBackward = storage.validateMovingBackward(3)
		let canMoveNestedForward = storage.validateMovingForward(5)
		let canMoveMissingBackward = storage.validateMovingBackward(404)

		// Assert
		#expect(canMoveFirstForward)
		#expect(!canMoveLastForward)
		#expect(!canMoveFirstBackward)
		#expect(canMoveLastBackward)
		#expect(canMoveNestedForward)
		#expect(!canMoveMissingBackward)
	}

	@Test
	func moveForwardAndBackwardUseIndexedSiblingDestinations() throws {
		// Arrange
		let storage = makeStorage()

		// Act
		try storage.moveForward(1)
		try storage.moveForward(3)
		try storage.moveBackward(3)
		try storage.moveBackward(1)
		try storage.moveForward(5)
		try storage.moveBackward(5)

		// Assert
		let moves = storage.invocations.filter { action in
			if case .moveItems = action {
				return true
			}
			return false
		}
		#expect(moves == [
			.moveItems(ids: [1], destination: .inRoot(atIndex: 2)),
			.moveItems(ids: [3], destination: .inRoot(atIndex: 1)),
			.moveItems(ids: [5], destination: .inItem(with: 10, atIndex: 3)),
			.moveItems(ids: [5], destination: .inItem(with: 10, atIndex: 0))
		])
	}
}

// MARK: - Helpers
private extension NodeStoringTests {

	func makeStorage() -> NodeStorageMock<TestItem<Int>> {
		let storage = NodeStorageMock<TestItem<Int>>()
		storage.stubs.rootIDs = [1, 2, 3]
		storage.stubs.parents = [
			4: 10,
			5: 10,
			6: 10
		]
		storage.stubs.children = [10: [4, 5, 6]]
		return storage
	}
}

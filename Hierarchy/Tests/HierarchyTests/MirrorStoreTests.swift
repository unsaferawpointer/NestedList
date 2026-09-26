import Testing
@testable import Hierarchy

struct MirrorStoreTests { }

// MARK: - Initialization
extension MirrorStoreTests {

	// ∅
	@Test
	func initCreatesEmptyStore() {
		// Arrange
		let store = MirrorStore<String, String>()

		// Act
		let identifiers = store.identifiers

		// Assert
		#expect(identifiers.isEmpty)
	}
}

// MARK: - Initialization
extension MirrorStoreTests {

	// A
	// └── B
	@Test
	func initStoresNodesAndCachesTheirDescendants() throws {
		// Arrange
		let child = Node(
			value: Container<String, String>.item(id: "B", content: "Child")
		)
		let root = Node(
			value: Container<String, String>.item(id: "A", content: "Root"),
			children: [child]
		)

		// Act
		let store = try MirrorStore(nodes: [root])

		// Assert
		#expect(store.identifiers == ["A", "B"])
		#expect(store.children(of: nil) == ["A"])
		#expect(store.children(of: "A") == ["B"])
		#expect(store["A"] == Resolved(id: "A", content: "Root"))
		#expect(store["B"] == Resolved(id: "B", content: "Child"))
	}
}

// MARK: - Insertion
extension MirrorStoreTests {

	// A
	// └── B
	@Test
	func insertPlacesNodesAtDestination() throws {
		// Arrange
		let root = Node(
			value: Container<String, String>.item(id: "A", content: "Root")
		)
		let child = Node(
			value: Container<String, String>.item(id: "B", content: "Child")
		)
		let store = try MirrorStore(nodes: [root])

		// Act
		try store.insert(nodes: [child], to: .inItem(with: "A", atIndex: 0))

		// Assert
		#expect(store.children(of: "A") == ["B"])
		#expect(store.identifiers == ["A", "B"])
	}

	// A (existing)
	// A (inserted)       ──▶ generated ID
	// B (inserted mirror) ──▶ generated ID
	@Test
	func insertRegeneratesCollidingIdentifiersAndUpdatesReferences() throws {
		// Arrange
		let existing = Node(
			value: Container<String, String>.item(id: "A", content: "Existing")
		)
		let insertedItem = Node(
			value: Container<String, String>.item(id: "A", content: "Inserted")
		)
		let insertedMirror = Node(
			value: Container<String, String>.mirror(id: "B", reference: "A")
		)
		let store = try MirrorStore(nodes: [existing])

		// Act
		try store.insert(nodes: [insertedItem, insertedMirror], to: .toRoot)

		// Assert
		#expect(store["A"]?.content == "Existing")
		#expect(store["B"]?.content == "Inserted")
		#expect(store.identifiers.count == 3)
	}

	// A
	// └── A // duplicate inside inserted tree
	@Test
	func insertThrowsForDuplicateIdentifiersInsideInsertedTree() throws {
		// Arrange
		let root = Node(
			value: Container<String, String>.item(id: "A", content: "Root"),
			children: [
				Node(
					value: Container<String, String>.item(id: "A", content: "Child")
				)
			]
		)
		let store = MirrorStore<String, String>()

		// Act & Assert
		#expect {
			try store.insert(nodes: [root], to: .toRoot)
		} throws: { error in
			guard let error = error as? MirrorStoreError else {
				return false
			}
			guard case .duplicateIdentifier = error else {
				return false
			}
			return true
		}
		#expect(store.identifiers.isEmpty)
	}

	// A
	// B ──▶ C (missing)
	@Test
	func insertRollsBackWhenValidationFails() throws {
		// Arrange
		let root = Node(
			value: Container<String, String>.item(id: "A", content: "Root")
		)
		let mirror = Node(
			value: Container<String, String>.mirror(id: "B", reference: "C")
		)
		let store = try MirrorStore(nodes: [root])

		// Act & Assert
		#expect {
			try store.insert(nodes: [mirror], to: .toRoot)
		} throws: { error in
			guard let error = error as? MirrorStoreError else {
				return false
			}
			guard case .missingReference = error else {
				return false
			}
			return true
		}
		#expect(store.identifiers == ["A"])
		#expect(store.children(of: nil) == ["A"])
	}
}

// MARK: - Deletion
extension MirrorStoreTests {

	// A
	// B ──▶ A
	@Test
	func deleteItemsRemovesMirrorPlacement() throws {
		// Arrange
		let item = Node(
			value: Container<String, String>.item(id: "A", content: "Item")
		)
		let mirror = Node(
			value: Container<String, String>.mirror(id: "B", reference: "A")
		)
		let store = try MirrorStore(nodes: [item, mirror])

		// Act
		store.deleteItems(["B"])

		// Assert
		#expect(store.identifiers == ["A"])
		#expect(store["A"]?.content == "Item")
		#expect(store["B"] == nil)
	}

	// A
	// └── B
	@Test
	func deleteItemsRemovesItemAndDescendants() throws {
		// Arrange
		let root = Node(
			value: Container<String, String>.item(id: "A", content: "Root"),
			children: [
				Node(
					value: Container<String, String>.item(id: "B", content: "Child")
				)
			]
		)
		let store = try MirrorStore(nodes: [root])

		// Act
		store.deleteItems(["A"])

		// Assert
		#expect(store.identifiers.isEmpty)
		#expect(store.children(of: nil).isEmpty)
	}

	// A
	// B ──▶ A
	@Test
	func deleteItemsRemovesDependentMirrorsWhenSourceIsDeleted() throws {
		// Arrange
		let item = Node(
			value: Container<String, String>.item(id: "A", content: "Item")
		)
		let mirror = Node(
			value: Container<String, String>.mirror(id: "B", reference: "A")
		)
		let store = try MirrorStore(nodes: [item, mirror])

		// Act
		store.deleteItems(["A"])

		// Assert
		#expect(store.identifiers.isEmpty)
		#expect(store.children(of: nil).isEmpty)
	}
}

// MARK: - Moving
extension MirrorStoreTests {

	// A
	// └── B
	// validating move B under A
	@Test
	func validateMoveReturnsTrueForValidDestination() throws {
		// Arrange
		let first = Node(
			value: Container<String, String>.item(id: "A", content: "First")
		)
		let second = Node(
			value: Container<String, String>.item(id: "B", content: "Second")
		)
		let store = try MirrorStore(nodes: [first, second])

		// Act
		let isValid = store.validateMove(["B"], to: .onItem(with: "A"))

		// Assert
		#expect(isValid)
		#expect(store.children(of: nil) == ["A", "B"])
		#expect(store.children(of: "A").isEmpty)
	}

	// A
	// └── B
	// validating move A under B // invalid
	@Test
	func validateMoveReturnsFalseWhenMovingNodeIntoDescendant() throws {
		// Arrange
		let child = Node(
			value: Container<String, String>.item(id: "B", content: "Child")
		)
		let root = Node(
			value: Container<String, String>.item(id: "A", content: "Root"),
			children: [child]
		)
		let store = try MirrorStore(nodes: [root])

		// Act
		let isValid = store.validateMove(["A"], to: .onItem(with: "B"))

		// Assert
		#expect(!isValid)
		#expect(store.children(of: nil) == ["A"])
		#expect(store.children(of: "A") == ["B"])
	}

	// A
	// └── M ──▶ B
	// validating move M under B // creates a cycle
	@Test
	func validateMoveReturnsFalseWhenMoveCreatesReferenceCycle() throws {
		// Arrange
		let mirror = Node(
			value: Container<String, String>.mirror(id: "M", reference: "B")
		)
		let first = Node(
			value: Container<String, String>.item(id: "A", content: "First"),
			children: [mirror]
		)
		let second = Node(
			value: Container<String, String>.item(id: "B", content: "Second")
		)
		let store = try MirrorStore(nodes: [first, second])

		// Act
		let isValid = store.validateMove(["M"], to: .onItem(with: "B"))

		// Assert
		#expect(!isValid)
		#expect(store.children(of: "A") == ["M"])
		#expect(store.children(of: "B").isEmpty)
	}

	// A
	// └── B
	@Test
	func moveItemsPlacesNodesAtDestination() throws {
		// Arrange
		let first = Node(
			value: Container<String, String>.item(id: "A", content: "First")
		)
		let second = Node(
			value: Container<String, String>.item(id: "B", content: "Second")
		)
		let store = try MirrorStore(nodes: [first, second])

		// Act
		try store.moveItems(["B"], to: .onItem(with: "A"))

		// Assert
		#expect(store.children(of: nil) == ["A"])
		#expect(store.children(of: "A") == ["B"])
		#expect(store.parent(of: "B") == "A")
	}

	// A
	// └── B
	// moving A under B // invalid
	@Test
	func moveItemsThrowsWhenMovingNodeIntoDescendant() throws {
		// Arrange
		let child = Node(
			value: Container<String, String>.item(id: "B", content: "Child")
		)
		let root = Node(
			value: Container<String, String>.item(id: "A", content: "Root"),
			children: [child]
		)
		let store = try MirrorStore(nodes: [root])

		// Act & Assert
		#expect {
			try store.moveItems(["A"], to: .onItem(with: "B"))
		} throws: { error in
			guard let error = error as? MirrorStoreError else {
				return false
			}
			guard case .movingIntoDescendant = error else {
				return false
			}
			return true
		}
		#expect(store.children(of: nil) == ["A"])
		#expect(store.children(of: "A") == ["B"])
	}

	// A
	// └── M ──▶ B
	// moving M under B // creates a cycle
	@Test
	func moveItemsRollsBackWhenMoveCreatesReferenceCycle() throws {
		// Arrange
		let mirror = Node(
			value: Container<String, String>.mirror(id: "M", reference: "B")
		)
		let first = Node(
			value: Container<String, String>.item(id: "A", content: "First"),
			children: [mirror]
		)
		let second = Node(
			value: Container<String, String>.item(id: "B", content: "Second")
		)
		let store = try MirrorStore(nodes: [first, second])

		// Act & Assert
		#expect {
			try store.moveItems(["M"], to: .onItem(with: "B"))
		} throws: { error in
			guard let error = error as? MirrorStoreError else {
				return false
			}
			guard case .referenceCycle = error else {
				return false
			}
			return true
		}
		#expect(store.children(of: "A") == ["M"])
		#expect(store.children(of: "B").isEmpty)
	}
}

// MARK: - Validation
extension MirrorStoreTests {

	// A (item)
	// A (mirror)
	@Test
	func initThrowsForDuplicateIdentifiers() {
		// Arrange
		let first = Node(
			value: Container<String, String>.item(id: "A", content: "First")
		)
		let second = Node(
			value: Container<String, String>.mirror(id: "A", reference: "B")
		)

		// Act & Assert
		#expect {
			_ = try MirrorStore(nodes: [first, second])
		} throws: { error in
			guard let error = error as? MirrorStoreError else {
				return false
			}
			guard case .duplicateIdentifier = error else {
				return false
			}
			return true
		}
	}

	// A ──▶ B (missing)
	@Test
	func initThrowsForMissingMirrorReference() {
		// Arrange
		let mirror = Node(
			value: Container<String, String>.mirror(
				id: "A",
				reference: "B"
			)
		)

		// Act & Assert
		#expect {
			_ = try MirrorStore(nodes: [mirror])
		} throws: { error in
			guard let error = error as? MirrorStoreError else {
				return false
			}
			guard case .missingReference = error else {
				return false
			}
			return true
		}
	}

	// A
	// B ──▶ A
	// C ──▶ B
	@Test
	func initThrowsWhenMirrorReferencesAnotherMirror() {
		// Arrange
		let item = Node(
			value: Container<String, String>.item(id: "A", content: "A")
		)
		let sourceMirror = Node(
			value: Container<String, String>.mirror(
				id: "B",
				reference: "A"
			)
		)
		let mirror = Node(
			value: Container<String, String>.mirror(
				id: "C",
				reference: "B"
			)
		)

		// Act & Assert
		#expect {
			_ = try MirrorStore(nodes: [item, sourceMirror, mirror])
		} throws: { error in
			guard let error = error as? MirrorStoreError else {
				return false
			}
			guard case .referenceIsMirror = error else {
				return false
			}
			return true
		}
	}

	// A
	// └── B ──▶ C
	// C
	// └── D ──▶ A
	@Test
	func initThrowsForCyclicMirrorReferences() {
		// Arrange
		let first = Node(
			value: Container<String, String>.item(id: "A", content: "First"),
			children: [
				Node(
					value: Container<String, String>.mirror(
						id: "B",
						reference: "C"
					)
				)
			]
		)
		let second = Node(
			value: Container<String, String>.item(id: "C", content: "Second"),
			children: [
				Node(
					value: Container<String, String>.mirror(
						id: "D",
						reference: "A"
					)
				)
			]
		)

		// Act & Assert
		#expect {
			_ = try MirrorStore(nodes: [first, second])
		} throws: { error in
			guard let error = error as? MirrorStoreError else {
				return false
			}
			guard case .referenceCycle = error else {
				return false
			}
			return true
		}
	}

	// A
	// └── B ──▶ A
	//     └── C // physical child, invalid
	@Test
	func initThrowsWhenMirrorHasPhysicalChildren() {
		// Arrange
		let mirror = Node(
			value: Container<String, String>.mirror(
				id: "B",
				reference: "A"
			),
			children: [
				Node(
					value: Container<String, String>.item(
						id: "C",
						content: "Child"
					)
				)
			]
		)
		let item = Node(
			value: Container<String, String>.item(id: "A", content: "Item")
		)

		// Act & Assert
		#expect {
			_ = try MirrorStore(nodes: [item, mirror])
		} throws: { error in
			guard let error = error as? MirrorStoreError else {
				return false
			}
			guard case .mirrorHasChildren = error else {
				return false
			}
			return true
		}
	}
}

import Testing
@testable import Hierarchy

struct MirrorStoreTests { }

// MARK: - Initialization
extension MirrorStoreTests {

	@Test
	func equalityComparesStoredHierarchy() throws {
		// Arrange
		let first = try MirrorStore(hierarchy: [
			Node(value: Container<String, String>.item(id: "A", content: "Value"))
		])
		let second = try MirrorStore(hierarchy: [
			Node(value: Container<String, String>.item(id: "A", content: "Value"))
		])
		let different = try MirrorStore(hierarchy: [
			Node(value: Container<String, String>.item(id: "A", content: "Other"))
		])

		// Act
		let equal = first == second
		let notEqual = first != different

		// Assert
		#expect(equal)
		#expect(notEqual)
	}
}

extension MirrorStoreTests {

	@Test
	func insertItemsAddsTreeNodes() throws {
		// Arrange
		let store = MirrorStore<String, String>()
		let root = Node(
			value: Container<String, String>.item(id: "A", content: "Root")
		)

		// Act
		try store.insertItems(from: [root], to: .toRoot)

		// Assert
		#expect(store.children(of: nil) == ["A"])
		#expect(store["A"]?.content == "Root")
	}

	@Test
	func insertAddsLeafContainersAtDestination() throws {
		// Arrange
		let store = MirrorStore<String, String>()
		let item = Container<String, String>.item(id: "A", content: "Root")

		// Act
		try store.insert([item], at: .toRoot)

		// Assert
		#expect(store.children(of: nil) == ["A"])
		#expect(store["A"]?.content == "Root")
	}
}

extension MirrorStoreTests {

	@Test
	func canMoveItemsMatchesMoveValidation() throws {
		// Arrange
		let root = Node(
			value: Container<String, String>.item(id: "A", content: "A"),
			children: [
				Node(value: Container<String, String>.item(id: "B", content: "B"))
			]
		)
		let store = try MirrorStore(nodes: [root])

		// Act
		let canMoveToRoot = store.canMoveItems(["B"], to: .toRoot)
		let canMoveIntoDescendant = store.canMoveItems(["A"], to: .onItem(with: "B"))

		// Assert
		#expect(canMoveToRoot == store.validateMove(["B"], to: .toRoot))
		#expect(!canMoveIntoDescendant)
	}
}

extension MirrorStoreTests {

	@Test
	func initWithHierarchyStoresRootsAndDescendants() throws {
		// Arrange
		let root = Node(
			value: Container<String, String>.item(id: "A", content: "Root"),
			children: [
				Node(value: Container<String, String>.item(id: "B", content: "Child"))
			]
		)

		// Act
		let store = try MirrorStore(hierarchy: [root])

		// Assert
		#expect(store.children(of: nil) == ["A"])
		#expect(store.children(of: "A") == ["B"])
		#expect(store.identifiers == ["A", "B"])
	}

	@Test
	func initWithLegacyResolvedHierarchyStoresItems() throws {
		// Arrange
		let root = Node(
			value: Resolved(id: "A", content: "Root"),
			children: [
				Node(value: Resolved(id: "B", content: "Child"))
			]
		)

		// Act
		let store = try MirrorStore<String, String>(hierarchy: [root])

		// Assert
		#expect(store.children(of: nil) == ["A"])
		#expect(store.children(of: "A") == ["B"])
		#expect(store["A"]?.content == "Root")
		#expect(store["B"]?.content == "Child")
	}
}

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

// MARK: - Mirror Source Validation
extension MirrorStoreTests {

	@Test
	func mirrorSourceIDs_excludesItemsCreatingReferenceCycles() throws {
		// Arrange
		let destination = Node(
			value: Container<String, String>.item(id: "A", content: "Destination")
		)
		let cyclicSource = Node(
			value: Container<String, String>.item(id: "B", content: "Cyclic source"),
			children: [
				Node(
					value: Container<String, String>.item(id: "C", content: "Nested source"),
					children: [
						Node(value: Container<String, String>.mirror(id: "M", reference: "A"))
					]
				)
			]
		)
		let source = Node(
			value: Container<String, String>.item(id: "D", content: "Source")
		)
		let store = try MirrorStore(nodes: [destination, cyclicSource, source])

		// Act
		let sourceIDs = store.mirrorSourceIDs(to: .onItem(with: "A"))

		// Assert
		#expect(sourceIDs == ["D"])
		#expect(store.children(of: "A").isEmpty)
	}

	@Test
	func mirrorSourceIDs_returnsEmptyForMirrorDestination() throws {
		// Arrange
		let source = Node(
			value: Container<String, String>.item(id: "A", content: "Source")
		)
		let destination = Node(
			value: Container<String, String>.mirror(id: "B", reference: "A")
		)
		let store = try MirrorStore(nodes: [source, destination])

		// Act
		let sourceIDs = store.mirrorSourceIDs(to: .onItem(with: "B"))

		// Assert
		#expect(sourceIDs.isEmpty)
	}
}

// MARK: - MirrorReading Helpers
extension MirrorStoreTests {

	@Test
	func mirrorReadingReconstructsNodesAndTracksRelationships() throws {
		// Arrange
		let root = Node(
			value: Container<String, String>.item(id: "A", content: "Root"),
			children: [
				Node(value: Container<String, String>.item(id: "B", content: "Leaf"))
			]
		)
		let store = try MirrorStore(nodes: [root])

		// Act
		let nodes = store.nodes(type: Node<Resolved<String, String>>.self)
		let descendants = store.descendantIDs(including: ["A"])
		let ancestors = store.ancestorIDs(including: "B")

		// Assert
		#expect(nodes.map(\.id) == ["A"])
		#expect(nodes[0].children.map(\.id) == ["B"])
		#expect(descendants == ["A", "B"])
		#expect(ancestors == ["A", "B"])
	}

	@Test
	func mirrorReadingEnumeratesLeavesAndMatchesValues() throws {
		// Arrange
		let root = Node(
			value: Container<String, String>.item(id: "A", content: "Root"),
			children: [
				Node(value: Container<String, String>.item(id: "B", content: "Leaf"))
			]
		)
		let store = try MirrorStore(nodes: [root])
		var enumerated: [String] = []

		// Act
		store.enumerate { enumerated.append($0.content) }
		let leavesMatch = store.allMatch(id: "A", keyPath: \.content, equalsTo: "Leaf")

		// Assert
		#expect(enumerated == ["Root", "Leaf"])
		#expect(leavesMatch)
	}
}

// MARK: - Content Updates
extension MirrorStoreTests {

	@Test
	func setUpdatesSelectedItemContent() throws {
		// Arrange
		let store = try MirrorStore(nodes: [
			Node(value: Container<TestContent, String>.item(
				id: "A",
				content: TestContent(title: "Original")
			))
		])

		// Act
		store.set(\.title, to: "Updated", for: ["A"], includingDescendants: false)

		// Assert
		#expect(store["A"]?.content.title == "Updated")
	}

	@Test
	func setUpdatesReferencedItemWhenSelectingMirror() throws {
		// Arrange
		let item = Node(
			value: Container<TestContent, String>.item(
				id: "A",
				content: TestContent(title: "Original")
			)
		)
		let mirror = Node(
			value: Container<TestContent, String>.mirror(id: "B", reference: "A")
		)
		let store = try MirrorStore(nodes: [item, mirror])

		// Act
		store.set(\.title, to: "Updated", for: ["B"], includingDescendants: false)

		// Assert
		#expect(store["A"]?.content.title == "Updated")
		#expect(store["B"]?.content.title == "Updated")
	}

	@Test
	func setUpdatesPhysicalDescendantsWhenRequested() throws {
		// Arrange
		let root = Node(
			value: Container<TestContent, String>.item(
				id: "A",
				content: TestContent(title: "Root")
			),
			children: [
				Node(value: Container<TestContent, String>.item(
					id: "B",
					content: TestContent(title: "Child")
				))
			]
		)
		let store = try MirrorStore(nodes: [root])

		// Act
		store.set(\.title, to: "Updated", for: ["A"], includingDescendants: true)

		// Assert
		#expect(store["A"]?.content.title == "Updated")
		#expect(store["B"]?.content.title == "Updated")
	}

	@Test
	func setRedirectsNestedMirrorToItsSource() throws {
		// Arrange
		let source = Node(
			value: Container<TestContent, String>.item(
				id: "S",
				content: TestContent(title: "Source")
			),
			children: [
				Node(value: Container<TestContent, String>.item(
					id: "T",
					content: TestContent(title: "Source child")
				))
			]
		)
		let root = Node(
			value: Container<TestContent, String>.item(
				id: "A",
				content: TestContent(title: "Root")
			),
			children: [
				Node(value: Container<TestContent, String>.mirror(id: "M", reference: "S"))
			]
		)
		let store = try MirrorStore(nodes: [source, root])

		// Act
		store.set(\.title, to: "Updated", for: ["A"], includingDescendants: true)

		// Assert
		#expect(store["A"]?.content.title == "Updated")
		#expect(store["S"]?.content.title == "Updated")
		#expect(store["T"]?.content.title == "Updated")
		#expect(store["M"]?.content.title == "Updated")
	}
}

private struct TestContent {
	var title: String
}

// MARK: - Moving Helpers
extension MirrorStoreTests {

	@Test
	func movingHelpersValidateSiblingBoundaries() throws {
		// Arrange
		let store = try MirrorStore(nodes: [
			Node(value: Container<String, String>.item(id: "A", content: "A")),
			Node(value: Container<String, String>.item(id: "B", content: "B")),
			Node(value: Container<String, String>.item(id: "C", content: "C"))
		])

		// Act
		let canMoveFirstBackward = store.validateMovingBackward("A")
		let canMoveMiddleBackward = store.validateMovingBackward("B")
		let canMoveMiddleForward = store.validateMovingForward("B")
		let canMoveLastForward = store.validateMovingForward("C")
		let canMoveMissing = store.validateMovingForward("missing")

		// Assert
		#expect(!canMoveFirstBackward)
		#expect(canMoveMiddleBackward)
		#expect(canMoveMiddleForward)
		#expect(!canMoveLastForward)
		#expect(!canMoveMissing)
	}

	@Test
	func moveForwardAndBackwardMoveNodeAmongSiblings() throws {
		// Arrange
		let store = try MirrorStore(nodes: [
			Node(value: Container<String, String>.item(id: "A", content: "A")),
			Node(value: Container<String, String>.item(id: "B", content: "B")),
			Node(value: Container<String, String>.item(id: "C", content: "C"))
		])

		// Act
		try store.moveForward("A")
		try store.moveBackward("C")

		// Assert
		#expect(store.children(of: nil) == ["B", "C", "A"])
	}

	@Test
	func moveToEndMovesNodesWithinTheirCurrentContainers() throws {
		// Arrange
		let nested = Node(
			value: Container<String, String>.item(id: "P", content: "Parent"),
			children: [
				Node(value: Container<String, String>.item(id: "A", content: "A")),
				Node(value: Container<String, String>.item(id: "B", content: "B"))
			]
		)
		let store = try MirrorStore(nodes: [
			nested,
			Node(value: Container<String, String>.item(id: "C", content: "C")),
			Node(value: Container<String, String>.item(id: "D", content: "D"))
		])

		// Act
		try store.moveToEnd(["A", "C"])

		// Assert
		#expect(store.children(of: "P") == ["B", "A"])
		#expect(store.children(of: nil) == ["P", "D", "C"])
	}
}

// MARK: - Snapshot Support
extension MirrorStoreTests {

	// A
	// ├── B
	// └── C ──▶ B
	@Test
	func snapshotBuildsResolvedHierarchy() throws {
		// Arrange
		let child = Node(
			value: Container<String, String>.item(id: "B", content: "Child")
		)
		let root = Node(
			value: Container<String, String>.item(id: "A", content: "Root"),
			children: [child]
		)
		let mirror = Node(
			value: Container<String, String>.mirror(id: "C", reference: "B")
		)
		let store = try MirrorStore(nodes: [root, mirror])

		// Act
		let snapshot = store.snapshot()

		// Assert
		#expect(snapshot.root == ["A", "C"])
		#expect(snapshot.hierarchy["A"] == ["B"])
		#expect(snapshot.hierarchy["C"] == [])
		#expect(snapshot[0] == Resolved(id: "A", content: "Root"))
		#expect(snapshot[1] == Resolved(id: "B", content: "Child"))
		#expect(snapshot[2] == Resolved(id: "C", content: "Child", isMirror: true))
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

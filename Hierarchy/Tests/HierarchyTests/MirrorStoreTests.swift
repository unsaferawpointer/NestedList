import Testing
@testable import Hierarchy

struct MirrorStoreTests { }

// MARK: - Initialization
extension MirrorStoreTests {

	@Test
	func initCreatesEmptyStore() {
		// Arrange
		let store = MirrorStore<TestItem<String>>()

		// Act
		let identifiers = store.identifiers

		// Assert
		#expect(identifiers.isEmpty)
	}

	@Test
	func initCopiesHierarchyIntoPrivateStorage() {
		// Arrange
		var hierarchy = [
			MirrorStoreTestNode(
				value: .item(value: TestItem(id: "A", title: "Original")),
				children: []
			)
		]

		// Act
		let store = MirrorStore<TestItem<String>>(hierarchy: hierarchy)
		hierarchy[0].value = .item(value: TestItem(id: "A", title: "Changed"))

		// Assert
		#expect(store["A"]?.content.title == "Original")
	}
}

// MARK: - NodeReading
extension MirrorStoreTests {

	@Test
	func subscriptReturnsOriginalItem() {
		// Arrange
		let base = NodeStorageMock<Container<TestItem<String>>>()
		base.stubs.items = [
			"A": .item(value: TestItem(id: "A", title: "Original"))
		]
		let store = makeStore(from: base)

		// Act
		let result = store["A"]

		// Assert
		#expect(result == Resolved(
			id: "A",
			content: TestItem(id: "A", title: "Original")
		))
	}

	@Test
	func subscriptReturnsOriginalItemThroughMirror() {
		// Arrange
		let base = NodeStorageMock<Container<TestItem<String>>>()
		base.stubs.items = [
			"A": .item(value: TestItem(id: "A", title: "Original")),
			"M(A)": .mirror(id: "M(A)", reference: "A")
		]
		let store = makeStore(from: base)

		// Act
		let result = store["M(A)"]

		// Assert
		#expect(result == Resolved(
			id: "M(A)",
			content: TestItem(id: "A", title: "Original"),
			isMirror: true
		))
	}

	@Test
	func subscriptReturnsNilForMissingItem() {
		// Arrange
		let base = NodeStorageMock<Container<TestItem<String>>>()
		let store = makeStore(from: base)

		// Act
		let result = store["missing"]

		// Assert
		#expect(result == nil)
	}

	@Test
	func identifiersReturnsStoredIdentifiers() {
		// Arrange
		let base = NodeStorageMock<Container<TestItem<String>>>()
		base.stubs.items = [
			"A": .item(value: TestItem(id: "A")),
			"M(A)": .mirror(id: "M(A)", reference: "A")
		]
		let store = makeStore(from: base)

		// Act
		let result = store.identifiers

		// Assert
		#expect(result == Set(["A", "M(A)"]))
	}

	@Test
	func descendantIDsTraversesStoredChildren() {
		// Arrange
		let base = NodeStorageMock<Container<TestItem<String>>>()
		base.stubs.items = [
			"A": .item(value: TestItem(id: "A")),
			"B": .item(value: TestItem(id: "B"))
		]
		base.stubs.children = ["A": ["B"]]
		let store = makeStore(from: base)

		// Act
		let result = store.descendantIDs(including: ["A"])

		// Assert
		#expect(result == Set(["A", "B"]))
	}

	@Test
	func parentReturnsStoredParentIdentifier() {
		// Arrange
		let base = NodeStorageMock<Container<TestItem<String>>>()
		base.stubs.items = [
			"A": .item(value: TestItem(id: "A")),
			"B": .item(value: TestItem(id: "B"))
		]
		base.stubs.parents = ["B": "A"]
		let store = makeStore(from: base)

		// Act
		let result = store.parent(of: "B")

		// Assert
		#expect(result == "A")
	}

	@Test
	func childrenReturnsStoredChildIdentifiers() {
		// Arrange
		let base = NodeStorageMock<Container<TestItem<String>>>()
		base.stubs.items = [
			"A": .item(value: TestItem(id: "A")),
			"B": .item(value: TestItem(id: "B")),
			"C": .item(value: TestItem(id: "C"))
		]
		base.stubs.children = ["A": ["B", "C"]]
		let store = makeStore(from: base)

		// Act
		let result = store.children(of: "A")

		// Assert
		#expect(result == ["B", "C"])
	}
}

// MARK: - Insertion
extension MirrorStoreTests {

	@Test
	func insertAddsItemsToStore() throws {
		// Arrange
		let base = NodeStorageMock<Container<TestItem<String>>>()
		let store = makeStore(from: base)
		let items = [
			TestItem(id: "A", title: "First"),
			TestItem(id: "B", title: "Second")
		]

		// Act
		try store.insert(items, at: .toRoot)

		// Assert
		#expect(store.children(of: nil) == ["A", "B"])
		#expect(store["A"]?.content == items[0])
		#expect(store["B"]?.content == items[1])
	}

	@Test
	func insertAddsItemToOriginal() throws {
		// Arrange
		let base = NodeStorageMock<Container<TestItem<String>>>()
		base.stubs.items = [
			"A": .item(value: TestItem(id: "A"))
		]
		let store = makeStore(from: base)

		// Act
		try store.insert(
			[TestItem(id: "B")],
			at: .onItem(with: "A")
		)

		// Assert
		#expect(store.identifiers == Set(["A", "B"]))
		#expect(store.children(of: "A") == ["B"])
	}

	@Test
	func insertDoesNotAddItemToMirror() throws {
		// Arrange
		let base = NodeStorageMock<Container<TestItem<String>>>()
		base.stubs.items = [
			"A": .item(value: TestItem(id: "A")),
			"M(A)": .mirror(id: "M(A)", reference: "A")
		]
		let store = makeStore(from: base)

		// Act
		try store.insert(
			[TestItem(id: "B")],
			at: .onItem(with: "M(A)")
		)

		// Assert
		#expect(store.identifiers == Set(["A", "M(A)"]))
		#expect(store.children(of: "M(A)").isEmpty)
	}

	@Test
	func insertDoesNotAddItemAtIndexToMirror() throws {
		// Arrange
		let base = NodeStorageMock<Container<TestItem<String>>>()
		base.stubs.items = [
			"A": .item(value: TestItem(id: "A")),
			"M(A)": .mirror(id: "M(A)", reference: "A")
		]
		let store = makeStore(from: base)

		// Act
		try store.insert(
			[TestItem(id: "B")],
			at: .inItem(with: "M(A)", atIndex: 0)
		)

		// Assert
		#expect(store.identifiers == Set(["A", "M(A)"]))
		#expect(store.children(of: "M(A)").isEmpty)
	}

	@Test
	func insertThrowsForMissingDestination() {
		// Arrange
		let base = NodeStorageMock<Container<TestItem<String>>>()
		let store = makeStore(from: base)

		// Act and Assert
		do {
			try store.insert([TestItem(id: "A")], at: .onItem(with: "missing"))
			Issue.record("Expected missing node error")
		} catch NodeStoreError.missingNode {
			#expect(store.identifiers.isEmpty)
		} catch {
			Issue.record("Expected missing node error")
		}
	}

	@Test
	func insertMirrorCreatesMirrorsAndReturnsTheirIdentifiers() throws {
		// Arrange
		let base = NodeStorageMock<Container<TestItem<String>>>()
		base.stubs.items = [
			"A": .item(value: TestItem(id: "A")),
			"B": .item(value: TestItem(id: "B")),
			"C": .item(value: TestItem(id: "C"))
		]
		let store = makeStore(from: base)

		// Act
		let result = try store.insertMirror(
			for: ["A", "B"],
			to: .inItem(with: "C", atIndex: 2)
		)

		// Assert
		#expect(store.children(of: "C") == result)
		#expect(result.count == 2)
		#expect(store[result[0]]?.content.id == "A")
		#expect(store[result[1]]?.content.id == "B")
		#expect(result.allSatisfy { store[$0]?.isMirror == true })
	}

	@Test
	func insertMirrorThrowsForMissingDestination() {
		// Arrange
		let base = NodeStorageMock<Container<TestItem<String>>>()
		base.stubs.items = [
			"A": .item(value: TestItem(id: "A"))
		]
		let store = makeStore(from: base)

		// Act and Assert
		do {
			_ = try store.insertMirror(for: ["A"], to: .onItem(with: "missing"))
			Issue.record("Expected missing node error")
		} catch NodeStoreError.missingNode {
			#expect(store.identifiers == Set(["A"]))
		} catch {
			Issue.record("Expected missing node error")
		}
	}

	@Test
	func canInsertMirrorAllowsValidDestination() {
		// Arrange
		let base = NodeStorageMock<Container<TestItem<String>>>()
		base.stubs.items = [
			"A": .item(value: TestItem(id: "A")),
			"B": .item(value: TestItem(id: "B"))
		]
		let store = makeStore(from: base)

		// Act
		let result = store.canInsertMirror(for: ["A"], to: .onItem(with: "B"))

		// Assert
		#expect(result)
	}

	@Test
	func canInsertMirrorRejectsMirrorAsDestination() {
		// Arrange
		let base = NodeStorageMock<Container<TestItem<String>>>()
		base.stubs.items = [
			"A": .item(value: TestItem(id: "A")),
			"M(A)": .mirror(id: "M(A)", reference: "A"),
			"B": .item(value: TestItem(id: "B"))
		]
		let store = makeStore(from: base)

		// Act
		let result = store.canInsertMirror(for: ["B"], to: .onItem(with: "M(A)"))

		// Assert
		#expect(!result)
	}

	@Test
	func canInsertMirrorRejectsOriginalAncestor() {
		// Arrange
		let base = NodeStorageMock<Container<TestItem<String>>>()
		base.stubs.items = [
			"A": .item(value: TestItem(id: "A")),
			"B": .item(value: TestItem(id: "B")),
			"C": .item(value: TestItem(id: "C"))
		]
		base.stubs.parents = ["B": "A", "C": "B"]
		let store = makeStore(from: base)

		// Act
		let insertIntoOriginal = store.canInsertMirror(for: ["A"], to: .onItem(with: "A"))
		let insertIntoChild = store.canInsertMirror(for: ["A"], to: .onItem(with: "B"))
		let insertIntoGrandchild = store.canInsertMirror(for: ["A"], to: .onItem(with: "C"))

		// Assert
		#expect(!insertIntoOriginal)
		#expect(!insertIntoChild)
		#expect(!insertIntoGrandchild)
	}

	@Test
	func insertMirrorRejectsInvalidDestinationWithoutInsertion() throws {
		// Arrange
		let base = NodeStorageMock<Container<TestItem<String>>>()
		base.stubs.items = [
			"A": .item(value: TestItem(id: "A")),
			"B": .item(value: TestItem(id: "B"))
		]
		base.stubs.parents = ["B": "A"]
		let store = makeStore(from: base)

		// Act
		let result = try store.insertMirror(for: ["A"], to: .onItem(with: "B"))

		// Assert
		#expect(result.isEmpty)
		#expect(store.identifiers == Set(["A", "B"]))
	}

	@Test
	func insertMirrorDerivedFromMirrorReferencesOriginal() throws {
		// Arrange
		let base = NodeStorageMock<Container<TestItem<String>>>()
		base.stubs.items = [
			"A": .item(value: TestItem(id: "A")),
			"M(A)": .mirror(id: "M(A)", reference: "A")
		]
		let store = makeStore(from: base)

		// Act
		let result = try store.insertMirror(for: ["M(A)"], to: .toRoot)

		// Assert
		let insertedID = try #require(result.first)
		#expect(store[insertedID]?.content.id == "A")
		#expect(store[insertedID]?.isMirror == true)
	}
}

// MARK: - Moving
extension MirrorStoreTests {

	/// ### 1. Original moves into its own subtree
	///
	/// ```text
	/// A
	/// └── B
	///     └── C
	///
	/// move A → B
	/// move A → C
	/// move B → C
	/// ```
	@Test
	func canMoveItemsRejectsMovingItemIntoDescendant() {
		// Arrange
		let base = NodeStorageMock<Container<TestItem<String>>>()
		base.stubs.items = [
			"A": .item(value: TestItem(id: "A")),
			"B": .item(value: TestItem(id: "B")),
			"C": .item(value: TestItem(id: "C"))
		]
		base.stubs.parents = ["B": "A", "C": "B"]
		let store = makeStore(from: base)

		// Act
		let moveRootToChild = store.canMoveItems(["A"], to: .onItem(with: "B"))
		let moveRootToGrandchild = store.canMoveItems(["A"], to: .onItem(with: "C"))
		let moveChildToGrandchild = store.canMoveItems(["B"], to: .onItem(with: "C"))

		// Assert
		#expect(!moveRootToChild)
		#expect(!moveRootToGrandchild)
		#expect(!moveChildToGrandchild)
	}

	/// ### Valid move to root
	///
	/// ```text
	/// A
	/// M(A) ──→ A
	///
	/// move M(A) → root
	/// ```
	@Test
	func canMoveItemsAllowsMovingToRoot() {
		// Arrange
		let base = NodeStorageMock<Container<TestItem<String>>>()
		base.stubs.items = [
			"A": .item(value: TestItem(id: "A")),
			"M(A)": .mirror(id: "M(A)", reference: "A")
		]
		let store = makeStore(from: base)

		// Act
		let result = store.canMoveItems(Set(["M(A)"]), to: .toRoot)

		// Assert
		#expect(result)
	}

	/// ### 2. Mirror is used as a parent
	///
	/// ```text
	/// A
	/// M(A) ──→ A
	/// B
	///
	/// move B → M(A)
	/// ```
	@Test
	func canMoveItemsRejectsMirrorAsDestination() {
		// Arrange
		let base = NodeStorageMock<Container<TestItem<String>>>()
		base.stubs.items = [
			"A": .item(value: TestItem(id: "A")),
			"M(A)": .mirror(id: "M(A)", reference: "A"),
			"B": .item(value: TestItem(id: "B"))
		]
		let store = makeStore(from: base)

		// Act
		let result = store.canMoveItems(["B"], to: .onItem(with: "M(A)"))

		// Assert
		#expect(!result)
	}

	/// ### 3. Mirror moves below its original
	///
	/// Directly below the original:
	///
	/// ```text
	/// A
	/// M(A) ──→ A
	///
	/// move M(A) → A
	/// ```
	///
	/// Below any physical descendant of the original:
	///
	/// ```text
	/// A
	/// └── B
	///     └── C
	///
	/// M(A) ──→ A
	///
	/// move M(A) → B
	/// move M(A) → C
	/// ```
	@Test
	func canMoveItemsRejectsMirrorBelowItsOriginal() {
		// Arrange
		let base = NodeStorageMock<Container<TestItem<String>>>()
		base.stubs.items = [
			"A": .item(value: TestItem(id: "A")),
			"B": .item(value: TestItem(id: "B")),
			"C": .item(value: TestItem(id: "C")),
			"M(A)": .mirror(id: "M(A)", reference: "A")
		]
		base.stubs.parents = ["B": "A", "C": "B"]
		let store = makeStore(from: base)

		// Act
		let moveToOriginal = store.canMoveItems(["M(A)"], to: .onItem(with: "A"))
		let moveToChild = store.canMoveItems(["M(A)"], to: .onItem(with: "B"))
		let moveToGrandchild = store.canMoveItems(["M(A)"], to: .onItem(with: "C"))

		// Assert
		#expect(!moveToOriginal)
		#expect(!moveToChild)
		#expect(!moveToGrandchild)
	}

	/// ### 4. Moved subtree contains a conflicting mirror
	///
	/// Directly below the mirror's original:
	///
	/// ```text
	/// A
	///
	/// B
	/// └── M(A) ──→ A
	///
	/// move B → A
	/// ```
	///
	/// Below a physical descendant of the mirror's original:
	///
	/// ```text
	/// A
	/// └── X
	///     └── Y
	///
	/// B
	/// └── M(A) ──→ A
	///
	/// move B → X
	/// move B → Y
	/// ```
	@Test
	func canMoveItemsRejectsSubtreeContainingMirrorOfNewAncestor() {
		// Arrange
		let base = NodeStorageMock<Container<TestItem<String>>>()
		base.stubs.items = [
			"A": .item(value: TestItem(id: "A")),
			"X": .item(value: TestItem(id: "X")),
			"Y": .item(value: TestItem(id: "Y")),
			"B": .item(value: TestItem(id: "B")),
			"M(A)": .mirror(id: "M(A)", reference: "A")
		]
		base.stubs.parents = ["X": "A", "Y": "X", "M(A)": "B"]
		base.stubs.children = ["B": ["M(A)"]]
		let store = makeStore(from: base)

		// Act
		let moveToOriginal = store.canMoveItems(["B"], to: .onItem(with: "A"))
		let moveToChild = store.canMoveItems(["B"], to: .onItem(with: "X"))
		let moveToGrandchild = store.canMoveItems(["B"], to: .onItem(with: "Y"))

		// Assert
		#expect(!moveToOriginal)
		#expect(!moveToChild)
		#expect(!moveToGrandchild)
	}

	/// ### Valid move outside the original's ancestor chain
	///
	/// ```text
	/// A
	///
	/// B
	/// └── C
	///
	/// M(A) ──→ A
	///
	/// move M(A) → C
	/// ```
	@Test
	func canMoveItemsAllowsMirrorOutsideOriginalAncestorChain() {
		// Arrange
		let base = NodeStorageMock<Container<TestItem<String>>>()
		base.stubs.items = [
			"A": .item(value: TestItem(id: "A")),
			"B": .item(value: TestItem(id: "B")),
			"M(A)": .mirror(id: "M(A)", reference: "A"),
			"C": .item(value: TestItem(id: "C"))
		]
		base.stubs.parents = ["C": "B"]
		let store = makeStore(from: base)

		// Act
		let result = store.canMoveItems(["M(A)"], to: .onItem(with: "C"))

		// Assert
		#expect(result)
	}

	/// ### A valid mirror move moves only the selected mirror
	///
	/// ```text
	/// A
	/// M1(A) ──→ A
	/// M2(A) ──→ A
	/// B
	///
	/// move M1(A) → B
	/// ```
	@Test
	func moveItemsMovesOnlySelectedMirror() throws {
		// Arrange
		let base = NodeStorageMock<Container<TestItem<String>>>()
		base.stubs.items = [
			"A": .item(value: TestItem(id: "A")),
			"M1(A)": .mirror(id: "M1(A)", reference: "A"),
			"M2(A)": .mirror(id: "M2(A)", reference: "A"),
			"B": .item(value: TestItem(id: "B"))
		]
		let store = makeStore(from: base)

		// Act
		try store.moveItems(Set(["M1(A)"]), to: .onItem(with: "B"))

		// Assert
		#expect(store.parent(of: "M1(A)") == "B")
		#expect(store.parent(of: "M2(A)") == nil)
		#expect(store.parent(of: "A") == nil)
	}

	/// ### A valid original move leaves its external mirrors in place
	///
	/// ```text
	/// A
	/// └── B
	///
	/// M(A) ──→ A
	/// C
	///
	/// move A → C
	/// ```
	@Test
	func moveItemsMovesOriginalWithoutMovingExternalMirror() throws {
		// Arrange
		let base = NodeStorageMock<Container<TestItem<String>>>()
		base.stubs.items = [
			"A": .item(value: TestItem(id: "A")),
			"B": .item(value: TestItem(id: "B")),
			"M(A)": .mirror(id: "M(A)", reference: "A"),
			"C": .item(value: TestItem(id: "C"))
		]
		base.stubs.parents = ["B": "A"]
		base.stubs.children = ["A": ["B"]]
		let store = makeStore(from: base)

		// Act
		try store.moveItems(["A"], to: .onItem(with: "C"))

		// Assert
		#expect(store.parent(of: "A") == "C")
		#expect(store.parent(of: "B") == "A")
		#expect(store.parent(of: "M(A)") == nil)
	}

	/// ### An invalid mirror move does not change the store
	///
	/// ```text
	/// A
	/// └── B
	///
	/// M(A) ──→ A
	///
	/// move M(A) → B
	/// ```
	@Test
	func moveItemsDoesNotPerformInvalidMove() throws {
		// Arrange
		let base = NodeStorageMock<Container<TestItem<String>>>()
		base.stubs.items = [
			"A": .item(value: TestItem(id: "A")),
			"B": .item(value: TestItem(id: "B")),
			"M(A)": .mirror(id: "M(A)", reference: "A")
		]
		base.stubs.parents = ["B": "A"]
		let store = makeStore(from: base)

		// Act
		try store.moveItems(["M(A)"], to: .onItem(with: "B"))

		// Assert
		#expect(store.parent(of: "M(A)") == nil)
	}

	/// ### Moving an item into its descendant is not performed
	///
	/// ```text
	/// A
	/// └── B
	///
	/// move A → B
	/// ```
	@Test
	func moveItemsDoesNotMoveItemIntoDescendant() throws {
		// Arrange
		let base = NodeStorageMock<Container<TestItem<String>>>()
		base.stubs.items = [
			"A": .item(value: TestItem(id: "A")),
			"B": .item(value: TestItem(id: "B"))
		]
		base.stubs.parents = ["B": "A"]
		let store = makeStore(from: base)

		// Act
		try store.moveItems(["A"], to: .onItem(with: "B"))

		// Assert
		#expect(store.parent(of: "A") == nil)
		#expect(store.parent(of: "B") == "A")
	}

	/// ### A valid mirror move to root is performed
	///
	/// ```text
	/// A
	/// M(A) ──→ A
	///
	/// move M(A) → root
	/// ```
	@Test
	func moveItemsMovesValidMirrorToRoot() throws {
		// Arrange
		let base = NodeStorageMock<Container<TestItem<String>>>()
		base.stubs.items = [
			"A": .item(value: TestItem(id: "A")),
			"B": .item(value: TestItem(id: "B")),
			"M(A)": .mirror(id: "M(A)", reference: "A")
		]
		base.stubs.parents = ["M(A)": "B"]
		let store = makeStore(from: base)

		// Act
		try store.moveItems(Set(["M(A)"]), to: .toRoot)

		// Assert
		#expect(store.parent(of: "M(A)") == nil)
		#expect(store.children(of: "B").isEmpty)
	}
}

// MARK: - Setting Properties
extension MirrorStoreTests {

	/// ### 1. Changing a property through a mirror updates only its original
	///
	/// ```text
	/// A
	/// └── B
	///
	/// M(A) ──→ A
	///
	/// set title on M(A), including descendants
	/// ```
	@Test
	func setUpdatesOriginalThroughMirrorWithoutUpdatingOriginalDescendants() {
		// Arrange
		let base = NodeStorageMock<Container<TestItem<String>>>()
		base.stubs.items = [
			"A": .item(value: TestItem(id: "A", title: "original")),
			"B": .item(value: TestItem(id: "B", title: "original")),
			"M(A)": .mirror(id: "M(A)", reference: "A")
		]
		base.stubs.parents = ["B": "A"]
		let store = makeStore(from: base)

		// Act
		store.set(
			\.title,
			to: "updated",
			for: ["M(A)"],
			includingDescendants: true
		)

		// Assert
		#expect(store["A"]?.content.title == "updated")
		#expect(store["B"]?.content.title == "original")
		#expect(store["M(A)"]?.content.title == "updated")
		#expect(store["M(A)"]?.isMirror == true)
	}

	/// ### 2. Changing descendants through an internal mirror updates its external original
	///
	/// ```text
	/// A
	/// └── B
	///     └── M(C) ──→ C
	///
	/// C
	///
	/// set title on A, including descendants
	/// ```
	@Test
	func setUpdatesPhysicalDescendantsAndOriginalReferencedByInternalMirror() {
		// Arrange
		let base = NodeStorageMock<Container<TestItem<String>>>()
		base.stubs.items = [
			"A": .item(value: TestItem(id: "A", title: "original")),
			"B": .item(value: TestItem(id: "B", title: "original")),
			"C": .item(value: TestItem(id: "C", title: "original")),
			"M(C)": .mirror(id: "M(C)", reference: "C")
		]
		base.stubs.parents = ["B": "A", "M(C)": "B"]
		base.stubs.children = [
			"A": ["B"],
			"B": ["M(C)"]
		]
		let store = makeStore(from: base)

		// Act
		store.set(
			\.title,
			to: "updated",
			for: ["A"],
			includingDescendants: true
		)

		// Assert
		#expect(store["A"]?.content.title == "updated")
		#expect(store["B"]?.content.title == "updated")
		#expect(store["C"]?.content.title == "updated")
		#expect(store["M(C)"]?.content.title == "updated")
		#expect(store["M(C)"]?.isMirror == true)
	}

	/// ### 3. Changing an original without descendants updates only that original
	///
	/// ```text
	/// A
	/// └── B
	///
	/// set title on A, excluding descendants
	/// ```
	@Test
	func setUpdatesOnlySelectedOriginalWhenDescendantsAreExcluded() {
		// Arrange
		let base = NodeStorageMock<Container<TestItem<String>>>()
		base.stubs.items = [
			"A": .item(value: TestItem(id: "A", title: "original")),
			"B": .item(value: TestItem(id: "B", title: "original"))
		]
		base.stubs.parents = ["B": "A"]
		let store = makeStore(from: base)

		// Act
		store.set(
			\.title,
			to: "updated",
			for: ["A"],
			includingDescendants: false
		)

		// Assert
		#expect(store["A"]?.content.title == "updated")
		#expect(store["B"]?.content.title == "original")
	}

	/// ### 4. Selecting an original and its mirrors updates the original once
	///
	/// ```text
	/// A
	/// M1(A) ──→ A
	/// M2(A) ──→ A
	///
	/// set title on A, M1(A), M2(A)
	/// ```
	@Test
	func setDeduplicatesOriginalSelectedThroughMultipleElements() {
		// Arrange
		let base = NodeStorageMock<Container<TestItem<String>>>()
		base.stubs.items = [
			"A": .item(value: TestItem(id: "A", title: "original")),
			"M1(A)": .mirror(id: "M1(A)", reference: "A"),
			"M2(A)": .mirror(id: "M2(A)", reference: "A")
		]
		let store = makeStore(from: base)

		// Act
		store.set(
			\.title,
			to: "updated",
			for: ["A", "M1(A)", "M2(A)"],
			includingDescendants: false
		)

		// Assert
		#expect(store["A"]?.content.title == "updated")
		#expect(store["M1(A)"]?.content.title == "updated")
		#expect(store["M2(A)"]?.content.title == "updated")
	}
}

// MARK: - Deletion
extension MirrorStoreTests {

	/// ### 1. Deleting a mirror removes only that mirror
	///
	/// ```text
	/// A
	/// M1(A) ──→ A
	/// M2(A) ──→ A
	///
	/// delete M1(A)
	/// ```
	@Test
	func deleteItemsDeletesOnlySelectedMirror() {
		// Arrange
		let base = NodeStorageMock<Container<TestItem<String>>>()
		base.stubs.items = [
			"A": .item(value: TestItem(id: "A")),
			"M1(A)": .mirror(id: "M1(A)", reference: "A"),
			"M2(A)": .mirror(id: "M2(A)", reference: "A")
		]
		let store = makeStore(from: base)

		// Act
		store.deleteItems(Set(["M1(A)"]))

		// Assert
		#expect(store.identifiers == Set(["A", "M2(A)"]))
	}

	/// ### 2. Deleting an original removes all its external mirrors
	///
	/// ```text
	/// A
	/// B
	/// M1(A) ──→ A
	/// M2(A) ──→ A
	///
	/// delete A
	/// ```
	@Test
	func deleteItemsDeletesOriginalAndItsExternalMirrors() {
		// Arrange
		let base = NodeStorageMock<Container<TestItem<String>>>()
		base.stubs.items = [
			"A": .item(value: TestItem(id: "A")),
			"B": .item(value: TestItem(id: "B")),
			"M1(A)": .mirror(id: "M1(A)", reference: "A"),
			"M2(A)": .mirror(id: "M2(A)", reference: "A")
		]
		let store = makeStore(from: base)

		// Act
		store.deleteItems(["A"])

		// Assert
		#expect(store.identifiers == Set(["B"]))
	}

	/// ### 3. Deleting a subtree preserves an original referenced by an internal mirror
	///
	/// ```text
	/// A
	///
	/// B
	/// └── M(A) ──→ A
	///
	/// delete B
	/// ```
	@Test
	func deleteItemsPreservesOriginalReferencedInsideDeletedSubtree() {
		// Arrange
		let base = NodeStorageMock<Container<TestItem<String>>>()
		base.stubs.items = [
			"A": .item(value: TestItem(id: "A")),
			"B": .item(value: TestItem(id: "B")),
			"M(A)": .mirror(id: "M(A)", reference: "A")
		]
		base.stubs.parents = ["M(A)": "B"]
		base.stubs.children = ["B": ["M(A)"]]
		let store = makeStore(from: base)

		// Act
		store.deleteItems(["B"])

		// Assert
		#expect(store.identifiers == Set(["A"]))
	}

	/// ### 4. Deleting an original subtree removes mirrors of its descendants
	///
	/// ```text
	/// A
	/// └── B
	///
	/// M(B) ──→ B
	///
	/// delete A
	/// ```
	@Test
	func deleteItemsDeletesMirrorsOfOriginalDescendants() {
		// Arrange
		let base = NodeStorageMock<Container<TestItem<String>>>()
		base.stubs.items = [
			"A": .item(value: TestItem(id: "A")),
			"B": .item(value: TestItem(id: "B")),
			"M(B)": .mirror(id: "M(B)", reference: "B")
		]
		base.stubs.parents = ["B": "A"]
		base.stubs.children = ["A": ["B"]]
		let store = makeStore(from: base)

		// Act
		store.deleteItems(["A"])

		// Assert
		#expect(store.identifiers.isEmpty)
	}
}

// MARK: - Storage Consistency
extension MirrorStoreTests {

	@Test
	func initValidatesStorageConsistencyByRemovingMirrorsWithoutOriginals() {
		// Arrange
		let base = NodeStorageMock<Container<TestItem<String>>>()
		base.stubs.items = [
			"A": .item(value: TestItem(id: "A")),
			"M(A)": .mirror(id: "M(A)", reference: "A"),
			"M(missing)": .mirror(id: "M(missing)", reference: "missing")
		]

		// Act
		let store = makeStore(from: base)

		// Assert
		#expect(store.identifiers == Set(["A", "M(A)"]))
		#expect(store["M(missing)"] == nil)
	}

	@Test
	func initValidatesStorageConsistencyByRemovingMirrorReferencesToMirrors() {
		// Arrange
		let base = NodeStorageMock<Container<TestItem<String>>>()
		base.stubs.items = [
			"A": .item(value: TestItem(id: "A")),
			"M(A)": .mirror(id: "M(A)", reference: "A"),
			"M(M(A))": .mirror(id: "M(M(A))", reference: "M(A)")
		]

		// Act
		let store = makeStore(from: base)

		// Assert
		#expect(store.identifiers == Set(["A", "M(A)"]))
		#expect(store["M(M(A))"] == nil)
	}

	@Test
	func initValidatesStorageConsistencyByRemovingMirrorsWithChildren() {
		// Arrange
		let base = NodeStorageMock<Container<TestItem<String>>>()
		base.stubs.items = [
			"A": .item(value: TestItem(id: "A")),
			"B": .item(value: TestItem(id: "B")),
			"M(A)": .mirror(id: "M(A)", reference: "A")
		]
		base.stubs.children = ["M(A)": ["B"]]

		// Act
		let store = makeStore(from: base)

		// Assert
		#expect(store.identifiers == Set(["A"]))
		#expect(store["M(A)"] == nil)
		#expect(store["B"] == nil)
	}

	@Test
	func initValidatesStorageConsistencyByRemovingMirrorsOfPhysicalAncestors() {
		// Arrange
		let base = NodeStorageMock<Container<TestItem<String>>>()
		base.stubs.items = [
			"A": .item(value: TestItem(id: "A")),
			"B": .item(value: TestItem(id: "B")),
			"M(A)": .mirror(id: "M(A)", reference: "A")
		]
		base.stubs.children = [
			"A": ["B"],
			"B": ["M(A)"]
		]

		// Act
		let store = makeStore(from: base)

		// Assert
		#expect(store.identifiers == Set(["A", "B"]))
		#expect(store.children(of: "A") == ["B"])
		#expect(store.children(of: "B").isEmpty)
	}

	@Test
	func initRepeatsStorageValidationAfterRemovingInvalidSubtree() {
		// Arrange
		let base = NodeStorageMock<Container<TestItem<String>>>()
		base.stubs.items = [
			"A": .item(value: TestItem(id: "A")),
			"B": .item(value: TestItem(id: "B")),
			"M(A)": .mirror(id: "M(A)", reference: "A"),
			"M(B)": .mirror(id: "M(B)", reference: "B")
		]
		base.stubs.children = ["M(A)": ["B"]]

		// Act
		let store = makeStore(from: base)

		// Assert
		#expect(store.identifiers == Set(["A"]))
	}

	@Test
	func initValidatesStorageConsistencyByPreservingValidMirrors() {
		// Arrange
		let base = NodeStorageMock<Container<TestItem<String>>>()
		base.stubs.items = [
			"A": .item(value: TestItem(id: "A")),
			"M(A)": .mirror(id: "M(A)", reference: "A")
		]

		// Act
		let store = makeStore(from: base)

		// Assert
		#expect(store.identifiers == Set(["A", "M(A)"]))
		#expect(store["M(A)"]?.content.id == "A")
	}
}

// MARK: - Helpers
private extension MirrorStoreTests {

	func makeStore(
		from fixture: NodeStorageMock<Container<TestItem<String>>>
	) -> MirrorStore<TestItem<String>> {
		var children = fixture.stubs.children
		for (id, parent) in fixture.stubs.parents where !(children[parent]?.contains(id) ?? false) {
			children[parent, default: []].append(id)
		}

		let childIDs = Set(children.values.flatMap { $0 })
		let rootIDs = fixture.stubs.rootIDs.isEmpty
			? fixture.stubs.items.keys.filter { !childIDs.contains($0) }.sorted()
			: fixture.stubs.rootIDs

		func node(for id: String) -> MirrorStoreTestNode {
			MirrorStoreTestNode(
				value: fixture.stubs.items[id]!,
				children: (children[id] ?? []).map(node(for:))
			)
		}

		return MirrorStore(hierarchy: rootIDs.map(node(for:)))
	}
}

// MARK: - Nested data structs
extension MirrorStoreTests {

	struct MirrorStoreTestNode: TreeNode {
		var value: Container<TestItem<String>>
		var children: [MirrorStoreTestNode]
	}
}

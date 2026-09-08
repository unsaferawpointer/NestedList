import Testing
@testable import Hierarchy

struct MirrorStoreTests { }

// MARK: - NodeReading
extension MirrorStoreTests {

	@Test
	func subscriptReturnsOriginalItem() {
		// Arrange
		let base = NodeStorageMock<Container<TestItem<String>>>()
		base.stubs.items = [
			"A": .item(value: TestItem(id: "A", title: "Original"))
		]
		let store = MirrorStore<TestItem<String>>(base: base)

		// Act
		let result = store["A"]

		// Assert
		#expect(result == TestItem(id: "A", title: "Original"))
	}

	@Test
	func subscriptReturnsOriginalItemThroughMirror() {
		// Arrange
		let base = NodeStorageMock<Container<TestItem<String>>>()
		base.stubs.items = [
			"A": .item(value: TestItem(id: "A", title: "Original")),
			"M(A)": .mirror(id: "M(A)", reference: "A")
		]
		let store = MirrorStore<TestItem<String>>(base: base)

		// Act
		let result = store["M(A)"]

		// Assert
		#expect(result == TestItem(id: "A", title: "Original"))
	}

	@Test
	func subscriptReturnsNilForMissingItem() {
		// Arrange
		let base = NodeStorageMock<Container<TestItem<String>>>()
		let store = MirrorStore<TestItem<String>>(base: base)

		// Act
		let result = store["missing"]

		// Assert
		#expect(result == nil)
	}

	@Test
	func identifiersReturnsBaseIdentifiers() {
		// Arrange
		let base = NodeStorageMock<Container<TestItem<String>>>()
		base.stubs.items = [
			"A": .item(value: TestItem(id: "A")),
			"M(A)": .mirror(id: "M(A)", reference: "A")
		]
		let store = MirrorStore<TestItem<String>>(base: base)

		// Act
		let result = store.identifiers

		// Assert
		#expect(result == Set(["A", "M(A)"]))
		#expect(base.invocations == [.identifiers])
	}

	@Test
	func descendantIDsTraversesBaseChildren() {
		// Arrange
		let base = NodeStorageMock<Container<TestItem<String>>>()
		base.stubs.items = [
			"A": .item(value: TestItem(id: "A")),
			"B": .item(value: TestItem(id: "B"))
		]
		base.stubs.children = ["A": ["B"]]
		let store = MirrorStore<TestItem<String>>(base: base)

		// Act
		let result = store.descendantIDs(including: ["A"])

		// Assert
		#expect(result == Set(["A", "B"]))
		#expect(base.invocations == [
			.item(id: "A"),
			.children(parent: "A"),
			.item(id: "B"),
			.children(parent: "B")
		])
	}

	@Test
	func parentReturnsBaseParentIdentifier() {
		// Arrange
		let base = NodeStorageMock<Container<TestItem<String>>>()
		base.stubs.parents = ["B": "A"]
		let store = MirrorStore<TestItem<String>>(base: base)

		// Act
		let result = store.parent(of: "B")

		// Assert
		#expect(result == "A")
		#expect(base.invocations == [.parent(id: "B")])
	}

	@Test
	func childrenReturnsBaseChildIdentifiers() {
		// Arrange
		let base = NodeStorageMock<Container<TestItem<String>>>()
		base.stubs.children = ["A": ["B", "C"]]
		let store = MirrorStore<TestItem<String>>(base: base)

		// Act
		let result = store.children(of: "A")

		// Assert
		#expect(result == ["B", "C"])
		#expect(base.invocations == [.children(parent: "A")])
	}
}

// MARK: - Insertion
extension MirrorStoreTests {

	@Test
	func insertWrapsItemsAndDelegatesToBase() throws {
		// Arrange
		let base = NodeStorageMock<Container<TestItem<String>>>()
		let store = MirrorStore<TestItem<String>>(base: base)
		let items = [
			TestItem(id: "A", title: "First"),
			TestItem(id: "B", title: "Second")
		]

		// Act
		try store.insert(items, at: .inRoot(atIndex: 1))

		// Assert
		#expect(base.invocations == [
			.insert(
				items: items.map { .item(value: $0) },
				destination: .inRoot(atIndex: 1)
			)
		])
	}

	@Test
	func insertPropagatesBaseError() {
		// Arrange
		let base = NodeStorageMock<Container<TestItem<String>>>()
		base.stubs.insertError = .missingNode
		let store = MirrorStore<TestItem<String>>(base: base)

		// Act and Assert
		do {
			try store.insert([TestItem(id: "A")], at: .onItem(with: "missing"))
			Issue.record("Expected missing node error")
		} catch NodeStoreError.missingNode {
			#expect(base.invocations == [
				.insert(
					items: [.item(value: TestItem(id: "A"))],
					destination: .onItem(with: "missing")
				)
			])
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
		let store = MirrorStore<TestItem<String>>(base: base)

		// Act
		let result = try store.insertMirror(
			for: ["A", "B"],
			to: .inItem(with: "C", atIndex: 2)
		)

		// Assert
		guard case let .insert(items, destination) = base.invocations.last else {
			Issue.record("Expected insert invocation")
			return
		}
		#expect(destination == .inItem(with: "C", atIndex: 2))
		#expect(items.map(\.id) == result)
		#expect(items.map(\.reference) == ["A", "B"])
	}

	@Test
	func insertMirrorPropagatesBaseError() {
		// Arrange
		let base = NodeStorageMock<Container<TestItem<String>>>()
		base.stubs.items = [
			"A": .item(value: TestItem(id: "A"))
		]
		base.stubs.insertError = .missingNode
		let store = MirrorStore<TestItem<String>>(base: base)

		// Act and Assert
		do {
			_ = try store.insertMirror(for: ["A"], to: .onItem(with: "missing"))
			Issue.record("Expected missing node error")
		} catch NodeStoreError.missingNode {
			guard case let .insert(items, destination) = base.invocations.last else {
				Issue.record("Expected insert invocation")
				return
			}
			#expect(destination == .onItem(with: "missing"))
			#expect(items.map(\.reference) == ["A"])
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
		let store = MirrorStore<TestItem<String>>(base: base)

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
		let store = MirrorStore<TestItem<String>>(base: base)

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
		let store = MirrorStore<TestItem<String>>(base: base)

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
		let store = MirrorStore<TestItem<String>>(base: base)

		// Act
		let result = try store.insertMirror(for: ["A"], to: .onItem(with: "B"))

		// Assert
		#expect(result.isEmpty)
		#expect(!base.invocations.contains { action in
			guard case .insert = action else {
				return false
			}
			return true
		})
	}

	@Test
	func insertMirrorDerivedFromMirrorReferencesOriginal() throws {
		// Arrange
		let base = NodeStorageMock<Container<TestItem<String>>>()
		base.stubs.items = [
			"A": .item(value: TestItem(id: "A")),
			"M(A)": .mirror(id: "M(A)", reference: "A")
		]
		let store = MirrorStore<TestItem<String>>(base: base)

		// Act
		_ = try store.insertMirror(for: ["M(A)"], to: .toRoot)

		// Assert
		guard case let .insert(items, destination) = base.invocations.last else {
			Issue.record("Expected insert invocation")
			return
		}
		#expect(destination == .toRoot)
		#expect(items.map(\.reference) == ["A"])
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
	func canMoveItemsReturnsFalseWhenBaseRejectsMove() {
		// Arrange
		let base = NodeStorageMock<Container<TestItem<String>>>()
		base.stubs.items = [
			"A": .item(value: TestItem(id: "A")),
			"B": .item(value: TestItem(id: "B")),
			"C": .item(value: TestItem(id: "C"))
		]
		base.stubs.parents = ["B": "A", "C": "B"]
		base.stubs.canMoveItems = false
		let store = MirrorStore<TestItem<String>>(base: base)

		// Act
		let moveRootToChild = store.canMoveItems(["A"], to: .onItem(with: "B"))
		let moveRootToGrandchild = store.canMoveItems(["A"], to: .onItem(with: "C"))
		let moveChildToGrandchild = store.canMoveItems(["B"], to: .onItem(with: "C"))

		// Assert
		#expect(!moveRootToChild)
		#expect(!moveRootToGrandchild)
		#expect(!moveChildToGrandchild)
		#expect(base.invocations == [
			.canMoveItems(ids: ["A"], destination: .onItem(with: "B")),
			.canMoveItems(ids: ["A"], destination: .onItem(with: "C")),
			.canMoveItems(ids: ["B"], destination: .onItem(with: "C"))
		])
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
		let store = MirrorStore<TestItem<String>>(base: base)

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
		let store = MirrorStore<TestItem<String>>(base: base)

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
		let store = MirrorStore<TestItem<String>>(base: base)

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
		let store = MirrorStore<TestItem<String>>(base: base)

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
		let store = MirrorStore<TestItem<String>>(base: base)

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
		let store = MirrorStore<TestItem<String>>(base: base)

		// Act
		try store.moveItems(Set(["M1(A)"]), to: .onItem(with: "B"))

		// Assert
		let moves = base.invocations.filter { action in
			guard case .moveItems = action else {
				return false
			}
			return true
		}
		#expect(moves == [
			.moveItems(ids: ["M1(A)"], destination: .onItem(with: "B"))
		])
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
		let store = MirrorStore<TestItem<String>>(base: base)

		// Act
		try store.moveItems(["A"], to: .onItem(with: "C"))

		// Assert
		let moves = base.invocations.filter { action in
			guard case .moveItems = action else {
				return false
			}
			return true
		}
		#expect(moves == [
			.moveItems(ids: ["A"], destination: .onItem(with: "C"))
		])
	}

	/// ### An invalid mirror move does not reach the base store
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
	func moveItemsDoesNotDelegateInvalidMove() throws {
		// Arrange
		let base = NodeStorageMock<Container<TestItem<String>>>()
		base.stubs.items = [
			"A": .item(value: TestItem(id: "A")),
			"B": .item(value: TestItem(id: "B")),
			"M(A)": .mirror(id: "M(A)", reference: "A")
		]
		base.stubs.parents = ["B": "A"]
		let store = MirrorStore<TestItem<String>>(base: base)

		// Act
		try store.moveItems(["M(A)"], to: .onItem(with: "B"))

		// Assert
		let moves = base.invocations.filter { action in
			guard case .moveItems = action else {
				return false
			}
			return true
		}
		#expect(moves.isEmpty)
	}

	/// ### A move rejected by the base store is not performed
	///
	/// ```text
	/// A
	/// B
	///
	/// move A → B
	/// ```
	@Test
	func moveItemsDoesNotDelegateWhenBaseRejectsMove() throws {
		// Arrange
		let base = NodeStorageMock<Container<TestItem<String>>>()
		base.stubs.items = [
			"A": .item(value: TestItem(id: "A")),
			"B": .item(value: TestItem(id: "B"))
		]
		base.stubs.canMoveItems = false
		let store = MirrorStore<TestItem<String>>(base: base)

		// Act
		try store.moveItems(["A"], to: .onItem(with: "B"))

		// Assert
		let moves = base.invocations.filter { action in
			guard case .moveItems = action else {
				return false
			}
			return true
		}
		#expect(moves.isEmpty)
		#expect(base.invocations.contains(
			.canMoveItems(ids: ["A"], destination: .onItem(with: "B"))
		))
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
	func moveItemsDelegatesValidMoveToRoot() throws {
		// Arrange
		let base = NodeStorageMock<Container<TestItem<String>>>()
		base.stubs.items = [
			"A": .item(value: TestItem(id: "A")),
			"M(A)": .mirror(id: "M(A)", reference: "A")
		]
		let store = MirrorStore<TestItem<String>>(base: base)

		// Act
		try store.moveItems(Set(["M(A)"]), to: .toRoot)

		// Assert
		let moves = base.invocations.filter { action in
			guard case .moveItems = action else {
				return false
			}
			return true
		}
		#expect(moves == [
			.moveItems(ids: ["M(A)"], destination: .toRoot)
		])
	}

	@Test
	func moveItemsPropagatesBaseError() {
		// Arrange
		let base = NodeStorageMock<Container<TestItem<String>>>()
		base.stubs.items = [
			"A": .item(value: TestItem(id: "A")),
			"B": .item(value: TestItem(id: "B"))
		]
		base.stubs.moveItemsError = .missingNode
		let store = MirrorStore<TestItem<String>>(base: base)

		// Act and Assert
		do {
			try store.moveItems(["A"], to: .onItem(with: "B"))
			Issue.record("Expected missing node error")
		} catch NodeStoreError.missingNode {
			#expect(base.invocations.contains(
				.moveItems(ids: ["A"], destination: .onItem(with: "B"))
			))
		} catch {
			Issue.record("Expected missing node error")
		}
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
		let store = MirrorStore<TestItem<String>>(base: base)

		// Act
		store.set(
			\.title,
			to: "updated",
			for: ["M(A)"],
			includingDescendants: true
		)

		// Assert
		#expect(base.stubs.items["A"] == .item(value: TestItem(id: "A", title: "updated")))
		#expect(base.stubs.items["B"] == .item(value: TestItem(id: "B", title: "original")))
		#expect(base.stubs.items["M(A)"] == .mirror(id: "M(A)", reference: "A"))
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
		let store = MirrorStore<TestItem<String>>(base: base)

		// Act
		store.set(
			\.title,
			to: "updated",
			for: ["A"],
			includingDescendants: true
		)

		// Assert
		#expect(base.stubs.items["A"] == .item(value: TestItem(id: "A", title: "updated")))
		#expect(base.stubs.items["B"] == .item(value: TestItem(id: "B", title: "updated")))
		#expect(base.stubs.items["C"] == .item(value: TestItem(id: "C", title: "updated")))
		#expect(base.stubs.items["M(C)"] == .mirror(id: "M(C)", reference: "C"))
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
		let store = MirrorStore<TestItem<String>>(base: base)

		// Act
		store.set(
			\.title,
			to: "updated",
			for: ["A"],
			includingDescendants: false
		)

		// Assert
		#expect(base.stubs.items["A"] == .item(value: TestItem(id: "A", title: "updated")))
		#expect(base.stubs.items["B"] == .item(value: TestItem(id: "B", title: "original")))
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
		let store = MirrorStore<TestItem<String>>(base: base)

		// Act
		store.set(
			\.title,
			to: "updated",
			for: ["A", "M1(A)", "M2(A)"],
			includingDescendants: false
		)

		// Assert
		let updates = base.invocations.filter { action in
			guard case .set = action else {
				return false
			}
			return true
		}
		#expect(updates == [.set(ids: ["A"], includingDescendants: false)])
		#expect(base.stubs.items["A"] == .item(value: TestItem(id: "A", title: "updated")))
		#expect(base.stubs.items["M1(A)"] == .mirror(id: "M1(A)", reference: "A"))
		#expect(base.stubs.items["M2(A)"] == .mirror(id: "M2(A)", reference: "A"))
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
		let store = MirrorStore<TestItem<String>>(base: base)

		// Act
		store.deleteItems(Set(["M1(A)"]))

		// Assert
		let deletions = base.invocations.compactMap { action -> Set<String>? in
			guard case let .deleteItems(ids) = action else {
				return nil
			}
			return Set(ids)
		}
		#expect(deletions == [Set(["M1(A)"])])
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
		let store = MirrorStore<TestItem<String>>(base: base)

		// Act
		store.deleteItems(["A"])

		// Assert
		let deletions = base.invocations.compactMap { action -> Set<String>? in
			guard case let .deleteItems(ids) = action else {
				return nil
			}
			return Set(ids)
		}
		#expect(deletions == [Set(["A", "M1(A)", "M2(A)"])])
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
		let store = MirrorStore<TestItem<String>>(base: base)

		// Act
		store.deleteItems(["B"])

		// Assert
		let deletions = base.invocations.compactMap { action -> Set<String>? in
			guard case let .deleteItems(ids) = action else {
				return nil
			}
			return Set(ids)
		}
		#expect(deletions == [Set(["B"])])
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
		let store = MirrorStore<TestItem<String>>(base: base)

		// Act
		store.deleteItems(["A"])

		// Assert
		let deletions = base.invocations.compactMap { action -> Set<String>? in
			guard case let .deleteItems(ids) = action else {
				return nil
			}
			return Set(ids)
		}
		#expect(deletions == [Set(["A", "M(B)"])])
	}
}

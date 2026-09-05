import Testing
@testable import Hierarchy

struct MirrorStoreTests { }

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
		base.stubs.descendants = [
			"A": ["A", "B", "C"],
			"B": ["B", "C"],
			"C": ["C"]
		]
		base.stubs.canMoveItems = false
		let store = MirrorStore<TestItem<String>>(base: base)

		// Act
		let moveRootToChild = store.canMoveItems(withIDs: ["A"], to: .onItem(with: "B"))
		let moveRootToGrandchild = store.canMoveItems(withIDs: ["A"], to: .onItem(with: "C"))
		let moveChildToGrandchild = store.canMoveItems(withIDs: ["B"], to: .onItem(with: "C"))

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
		base.stubs.descendants = ["A": ["A"], "M(A)": ["M(A)"]]
		let store = MirrorStore<TestItem<String>>(base: base)

		// Act
		let result = store.canMoveItems(withIDs: Set(["M(A)"]), to: .toRoot)

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
		base.stubs.descendants = ["A": ["A"], "M(A)": ["M(A)"], "B": ["B"]]
		let store = MirrorStore<TestItem<String>>(base: base)

		// Act
		let result = store.canMoveItems(withIDs: ["B"], to: .onItem(with: "M(A)"))

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
		base.stubs.descendants = [
			"A": ["A", "B", "C"],
			"B": ["B", "C"],
			"C": ["C"],
			"M(A)": ["M(A)"]
		]
		let store = MirrorStore<TestItem<String>>(base: base)

		// Act
		let moveToOriginal = store.canMoveItems(withIDs: ["M(A)"], to: .onItem(with: "A"))
		let moveToChild = store.canMoveItems(withIDs: ["M(A)"], to: .onItem(with: "B"))
		let moveToGrandchild = store.canMoveItems(withIDs: ["M(A)"], to: .onItem(with: "C"))

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
		base.stubs.descendants = [
			"A": ["A", "X", "Y"],
			"X": ["X", "Y"],
			"Y": ["Y"],
			"B": ["B", "M(A)"],
			"M(A)": ["M(A)"]
		]
		let store = MirrorStore<TestItem<String>>(base: base)

		// Act
		let moveToOriginal = store.canMoveItems(withIDs: ["B"], to: .onItem(with: "A"))
		let moveToChild = store.canMoveItems(withIDs: ["B"], to: .onItem(with: "X"))
		let moveToGrandchild = store.canMoveItems(withIDs: ["B"], to: .onItem(with: "Y"))

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
		base.stubs.descendants = [
			"A": ["A"],
			"B": ["B", "C"],
			"M(A)": ["M(A)"],
			"C": ["C"]
		]
		let store = MirrorStore<TestItem<String>>(base: base)

		// Act
		let result = store.canMoveItems(withIDs: ["M(A)"], to: .onItem(with: "C"))

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
	func moveItemsMovesOnlySelectedMirror() {
		// Arrange
		let base = NodeStorageMock<Container<TestItem<String>>>()
		base.stubs.items = [
			"A": .item(value: TestItem(id: "A")),
			"M1(A)": .mirror(id: "M1(A)", reference: "A"),
			"M2(A)": .mirror(id: "M2(A)", reference: "A"),
			"B": .item(value: TestItem(id: "B"))
		]
		base.stubs.descendants = ["M1(A)": ["M1(A)"]]
		let store = MirrorStore<TestItem<String>>(base: base)

		// Act
		store.moveItems(withIDs: Set(["M1(A)"]), to: .onItem(with: "B"))

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
	func moveItemsMovesOriginalWithoutMovingExternalMirror() {
		// Arrange
		let base = NodeStorageMock<Container<TestItem<String>>>()
		base.stubs.items = [
			"A": .item(value: TestItem(id: "A")),
			"B": .item(value: TestItem(id: "B")),
			"M(A)": .mirror(id: "M(A)", reference: "A"),
			"C": .item(value: TestItem(id: "C"))
		]
		base.stubs.parents = ["B": "A"]
		base.stubs.descendants = ["A": ["A", "B"]]
		let store = MirrorStore<TestItem<String>>(base: base)

		// Act
		store.moveItems(withIDs: ["A"], to: .onItem(with: "C"))

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
	func moveItemsDoesNotDelegateInvalidMove() {
		// Arrange
		let base = NodeStorageMock<Container<TestItem<String>>>()
		base.stubs.items = [
			"A": .item(value: TestItem(id: "A")),
			"B": .item(value: TestItem(id: "B")),
			"M(A)": .mirror(id: "M(A)", reference: "A")
		]
		base.stubs.parents = ["B": "A"]
		base.stubs.descendants = ["M(A)": ["M(A)"]]
		let store = MirrorStore<TestItem<String>>(base: base)

		// Act
		store.moveItems(withIDs: ["M(A)"], to: .onItem(with: "B"))

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
	func moveItemsDoesNotDelegateWhenBaseRejectsMove() {
		// Arrange
		let base = NodeStorageMock<Container<TestItem<String>>>()
		base.stubs.items = [
			"A": .item(value: TestItem(id: "A")),
			"B": .item(value: TestItem(id: "B"))
		]
		base.stubs.descendants = ["A": ["A"]]
		base.stubs.canMoveItems = false
		let store = MirrorStore<TestItem<String>>(base: base)

		// Act
		store.moveItems(withIDs: ["A"], to: .onItem(with: "B"))

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
	func moveItemsDelegatesValidMoveToRoot() {
		// Arrange
		let base = NodeStorageMock<Container<TestItem<String>>>()
		base.stubs.items = [
			"A": .item(value: TestItem(id: "A")),
			"M(A)": .mirror(id: "M(A)", reference: "A")
		]
		base.stubs.descendants = ["M(A)": ["M(A)"]]
		let store = MirrorStore<TestItem<String>>(base: base)

		// Act
		store.moveItems(withIDs: Set(["M(A)"]), to: .toRoot)

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
		base.stubs.descendants = [
			"A": ["A", "B"],
			"M(A)": ["M(A)"]
		]
		let store = MirrorStore<TestItem<String>>(base: base)

		// Act
		store.set(
			\.title,
			to: "updated",
			forItemsWithIDs: ["M(A)"],
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
		base.stubs.descendants = ["A": ["A", "B", "M(C)"]]
		let store = MirrorStore<TestItem<String>>(base: base)

		// Act
		store.set(
			\.title,
			to: "updated",
			forItemsWithIDs: ["A"],
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
		base.stubs.descendants = ["A": ["A", "B"]]
		let store = MirrorStore<TestItem<String>>(base: base)

		// Act
		store.set(
			\.title,
			to: "updated",
			forItemsWithIDs: ["A"],
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
			forItemsWithIDs: ["A", "M1(A)", "M2(A)"],
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
		base.stubs.descendants = ["M1(A)": ["M1(A)"]]
		let store = MirrorStore<TestItem<String>>(base: base)

		// Act
		store.deleteItems(withIDs: Set(["M1(A)"]))

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
		base.stubs.descendants = ["A": ["A"]]
		let store = MirrorStore<TestItem<String>>(base: base)

		// Act
		store.deleteItems(withIDs: ["A"])

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
		base.stubs.descendants = ["B": ["B", "M(A)"]]
		let store = MirrorStore<TestItem<String>>(base: base)

		// Act
		store.deleteItems(withIDs: ["B"])

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
		base.stubs.descendants = ["A": ["A", "B"]]
		let store = MirrorStore<TestItem<String>>(base: base)

		// Act
		store.deleteItems(withIDs: ["A"])

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

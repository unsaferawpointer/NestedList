import Testing
@testable import Hierarchy

struct ResolvedTests { }

// MARK: - Initialization
extension ResolvedTests {

	@Test
	func initStoresIdentifierContentAndMirrorFlag() {
		// Arrange
		let content = TestItem(id: "Content", title: "Original")

		// Act
		let resolved = Resolved(id: "A", content: content, isMirror: true)

		// Assert
		#expect(resolved.id == "A")
		#expect(resolved.content == content)
		#expect(resolved.isMirror)
	}

	@Test
	func initCreatesOriginalByDefault() {
		// Arrange
		let content = TestItem(id: "Content", title: "Original")

		// Act
		let resolved = Resolved(id: "A", content: content)

		// Assert
		#expect(!resolved.isMirror)
	}
}

// MARK: - MutableIdentifiable
extension ResolvedTests {

	@Test
	func idCanBeUpdated() {
		// Arrange
		var resolved = Resolved(
			id: "A",
			content: TestItem(id: "Content", title: "Original")
		)

		// Act
		resolved.id = "B"

		// Assert
		#expect(resolved.id == "B")
	}
}

// MARK: - Equatable
extension ResolvedTests {

	@Test
	func equalityIncludesMirrorFlag() {
		// Arrange
		let content = TestItem(id: "Content", title: "Original")
		let original = Resolved(id: "A", content: content)
		let mirror = Resolved(id: "A", content: content, isMirror: true)

		// Act
		let areEqual = original == mirror

		// Assert
		#expect(!areEqual)
	}

	@Test
	func equalityIncludesIdentifier() {
		// Arrange
		let content = TestItem(id: "Content", title: "Original")
		let first = Resolved(id: "A", content: content)
		let second = Resolved(id: "B", content: content)

		// Act
		let areEqual = first == second

		// Assert
		#expect(!areEqual)
	}
}

// MARK: - Hashable
extension ResolvedTests {

	@Test
	func hashingIncludesMirrorFlag() {
		// Arrange
		let content = TestItem(id: "Content", title: "Original")
		let original = Resolved(id: "A", content: content)
		let mirror = Resolved(id: "A", content: content, isMirror: true)

		// Act
		let values: Set = [original, mirror]

		// Assert
		#expect(values.count == 2)
	}
}

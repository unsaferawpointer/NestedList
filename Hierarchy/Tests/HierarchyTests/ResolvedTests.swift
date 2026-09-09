import Testing
@testable import Hierarchy

struct ResolvedTests { }

// MARK: - Initialization
extension ResolvedTests {

	@Test
	func initStoresContentAndMirrorFlag() {
		// Arrange
		let content = TestItem(id: "A", title: "Original")

		// Act
		let resolved = Resolved(content: content, isMirror: true)

		// Assert
		#expect(resolved.content == content)
		#expect(resolved.isMirror)
	}

	@Test
	func initCreatesOriginalByDefault() {
		// Arrange
		let content = TestItem(id: "A", title: "Original")

		// Act
		let resolved = Resolved(content: content)

		// Assert
		#expect(!resolved.isMirror)
	}
}

// MARK: - MutableIdentifiable
extension ResolvedTests {

	@Test
	func idProxiesContentIdentifier() {
		// Arrange
		var resolved = Resolved(
			content: TestItem(id: "A", title: "Original")
		)

		// Act
		resolved.id = "B"

		// Assert
		#expect(resolved.id == "B")
		#expect(resolved.content.id == "B")
	}
}

// MARK: - Equatable
extension ResolvedTests {

	@Test
	func equalityIncludesMirrorFlag() {
		// Arrange
		let content = TestItem(id: "A", title: "Original")
		let original = Resolved(content: content)
		let mirror = Resolved(content: content, isMirror: true)

		// Act
		let areEqual = original == mirror

		// Assert
		#expect(!areEqual)
	}
}

// MARK: - Hashable
extension ResolvedTests {

	@Test
	func hashingIncludesMirrorFlag() {
		// Arrange
		let content = TestItem(id: "A", title: "Original")
		let original = Resolved(content: content)
		let mirror = Resolved(content: content, isMirror: true)

		// Act
		let values: Set = [original, mirror]

		// Assert
		#expect(values.count == 2)
	}
}

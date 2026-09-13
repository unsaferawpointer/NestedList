import Testing
@testable import Hierarchy

struct ContainerTests { }

// MARK: - MutableIdentifiable
extension ContainerTests {

	@Test
	func itemUsesStoredIdentifier() {
		// Arrange
		let container = Container.item(
			id: "A",
			content: "Original"
		)

		// Act and Assert
		#expect(container.id == "A")
	}

	@Test
	func settingItemIdentifierPreservesContent() {
		// Arrange
		var container = Container.item(
			id: "A",
			content: "Original"
		)

		// Act
		container.id = "B"

		// Assert
		#expect(container == .item(id: "B", content: "Original"))
	}

	@Test
	func mirrorUsesOwnIdentifier() {
		// Arrange
		let container = Container<String, String>.mirror(
			id: "M(A)",
			reference: "A"
		)

		// Act and Assert
		#expect(container.id == "M(A)")
	}

	@Test
	func settingMirrorIdentifierPreservesReference() {
		// Arrange
		var container = Container<String, String>.mirror(
			id: "M(A)",
			reference: "A"
		)

		// Act
		container.id = "M2(A)"

		// Assert
		#expect(container == .mirror(id: "M2(A)", reference: "A"))
	}
}

// MARK: - Computed Properties
extension ContainerTests {

	@Test
	func itemExposesContentWithoutReference() {
		// Arrange
		let content = "Original"
		let container = Container.item(id: "A", content: content)

		// Act and Assert
		#expect(container.itemContent == content)
		#expect(container.reference == nil)
	}

	@Test
	func mirrorExposesReference() {
		// Arrange
		let container = Container<String, String>.mirror(
			id: "M(A)",
			reference: "A"
		)

		// Act and Assert
		#expect(container.reference == "A")
	}

	@Test
	func settingItemContentPreservesIdentifier() {
		// Arrange
		var container = Container.item(
			id: "A",
			content: "Original"
		)

		// Act
		container.itemContent = "Updated"

		// Assert
		#expect(container == .item(id: "A", content: "Updated"))
	}
}

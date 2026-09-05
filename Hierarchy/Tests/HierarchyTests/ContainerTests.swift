import Testing
@testable import Hierarchy

struct ContainerTests { }

// MARK: - MutableIdentifiable
extension ContainerTests {

	@Test
	func itemUsesValueIdentifier() {
		// Arrange
		let container = Container.item(
			value: TestItem(id: "A", title: "Original")
		)

		// Act and Assert
		#expect(container.id == "A")
	}

	@Test
	func settingItemIdentifierUpdatesValue() {
		// Arrange
		var container = Container.item(
			value: TestItem(id: "A", title: "Original")
		)

		// Act
		container.id = "B"

		// Assert
		#expect(container == .item(value: TestItem(id: "B", title: "Original")))
	}

	@Test
	func mirrorUsesOwnIdentifier() {
		// Arrange
		let container = Container<TestItem<String>>.mirror(
			id: "M(A)",
			reference: "A"
		)

		// Act and Assert
		#expect(container.id == "M(A)")
	}

	@Test
	func settingMirrorIdentifierPreservesReference() {
		// Arrange
		var container = Container<TestItem<String>>.mirror(
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
	func itemExposesValueWithoutReference() {
		// Arrange
		let value = TestItem(id: "A", title: "Original")
		let container = Container.item(value: value)

		// Act and Assert
		#expect(container.itemValue == value)
		#expect(container.reference == nil)
	}

	@Test
	func mirrorExposesReference() {
		// Arrange
		let container = Container<TestItem<String>>.mirror(
			id: "M(A)",
			reference: "A"
		)

		// Act and Assert
		#expect(container.reference == "A")
	}

	@Test
	func settingItemValueReplacesValue() {
		// Arrange
		var container = Container.item(
			value: TestItem(id: "A", title: "Original")
		)

		// Act
		container.itemValue = TestItem(id: "B", title: "Updated")

		// Assert
		#expect(container == .item(value: TestItem(id: "B", title: "Updated")))
	}
}

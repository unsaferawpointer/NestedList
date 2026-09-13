import Testing
@testable import Hierarchy

struct MirrorStoreTests { }

// MARK: - Initialization
extension MirrorStoreTests {

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

// MARK: - MirrorReading
extension MirrorStoreTests {

	@Test
	func identifiersReturnsBaseIdentifiers() {
		// Arrange
		let base = NodeStorageMock<Container<String, String>>()
		base.stubs.items = [
			"A": .item(id: "A", content: "Original"),
			"M(A)": .mirror(id: "M(A)", reference: "A")
		]
		let store = MirrorStore(base: base)

		// Act
		let identifiers = store.identifiers

		// Assert
		#expect(identifiers == Set(["A", "M(A)"]))
	}

	@Test
	func parentReturnsBaseParent() {
		// Arrange
		let base = NodeStorageMock<Container<String, String>>()
		base.stubs.parents = ["B": "A"]
		let store = MirrorStore(base: base)

		// Act
		let parent = store.parent(of: "B")

		// Assert
		#expect(parent == "A")
	}

	@Test
	func childrenReturnsBaseChildren() {
		// Arrange
		let base = NodeStorageMock<Container<String, String>>()
		base.stubs.children = ["A": ["B", "C"]]
		let store = MirrorStore(base: base)

		// Act
		let children = store.children(of: "A")

		// Assert
		#expect(children == ["B", "C"])
	}

	@Test
	func subscriptReturnsOriginalContent() {
		// Arrange
		let base = NodeStorageMock<Container<String, String>>()
		base.stubs.items = [
			"A": .item(id: "A", content: "Original")
		]
		let store = MirrorStore(base: base)

		// Act
		let item = store["A"]

		// Assert
		#expect(item == Resolved(id: "A", content: "Original"))
		#expect(item?.isMirror == false)
	}

	@Test
	func subscriptResolvesMirrorContent() {
		// Arrange
		let base = NodeStorageMock<Container<String, String>>()
		base.stubs.items = [
			"A": .item(id: "A", content: "Original"),
			"M(A)": .mirror(id: "M(A)", reference: "A")
		]
		let store = MirrorStore(base: base)

		// Act
		let item = store["M(A)"]

		// Assert
		#expect(item == Resolved(id: "M(A)", content: "Original", isMirror: true))
		#expect(item?.isMirror == true)
	}

	@Test
	func subscriptReturnsNilForMissingIdentifier() {
		// Arrange
		let base = NodeStorageMock<Container<String, String>>()
		let store = MirrorStore(base: base)

		// Act
		let item = store["missing"]

		// Assert
		#expect(item == nil)
	}
}

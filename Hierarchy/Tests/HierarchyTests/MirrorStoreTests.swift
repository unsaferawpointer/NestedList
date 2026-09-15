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

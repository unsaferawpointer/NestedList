//
//  DocumentAssemblyTests.swift
//  macOSTests
//

import AppKit
import CoreModule
import Testing
@testable import Nested_List

@MainActor
struct DocumentAssemblyTests { }

// MARK: - List presentation
extension DocumentAssemblyTests {

	@Test func buildReturnsListContentViewController() {
		// Arrange
		let storage = makeStorage()

		// Act
		let viewController = DocumentAssembly.build(storage: storage)

		// Assert
		#expect(viewController is ContentViewController)
	}
}

// MARK: - Content toolbar
extension DocumentAssemblyTests {

	@Test func toolbarContainsOnlyNewItemControl() throws {
		// Arrange
		let viewController = try #require(DocumentAssembly.build(storage: makeStorage()) as? ContentViewController)

		// Act
		let identifiers = viewController.toolbarAllowedItemIdentifiers(viewController.toolbar)

		// Assert
		#expect(identifiers == [.space, .newItem])
	}
}

// MARK: - Nested data structs
private extension DocumentAssemblyTests {

	func makeStorage() -> DocumentStorage<DocumentContent> {
		DocumentStorage(
			stateProvider: StateProvider(initialState: .empty),
			contentProvider: DataProvider(),
			undoManager: nil
		)
	}
}

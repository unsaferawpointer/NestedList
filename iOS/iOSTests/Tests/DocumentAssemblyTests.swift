//
//  DocumentAssemblyTests.swift
//  iOSTests
//

import CoreModule
import Testing
import UIKit
@testable import iOS

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
		#expect(viewController is TableViewController)
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

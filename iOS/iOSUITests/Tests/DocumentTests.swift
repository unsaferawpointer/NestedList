//
//  DocumentTests.swift
//  iOSUITests
//
//  Created by Anton Cherkasov on 03.02.2025.
//

import XCTest

final class DocumentTests: XCTestCase {

	override func setUpWithError() throws {
		continueAfterFailure = false
	}

	override func tearDownWithError() throws { }
}

extension DocumentTests {

	@MainActor
	func test_createNew() throws {

		let window = launch()

		let page = DocumentPage(window: window)
		page.createDocument()
		page.tapAddButton()

		let details = DetailsPage(window: window)
		details.enterTitle("New Item")
		details.enterDescription("Item note")

		XCTAssertFalse(details.hintExists())

		details.tapSaveButton()

		// Assert
		XCTAssertEqual("New Item", page.text(for: 0))
		XCTAssertEqual("Item note", page.detail(for: 0))
	}
}

// MARK: - Helpers
private extension DocumentTests {

	@MainActor
	func launch() -> XCUIElement {

		let app = XCUIApplication()
		app.launch()

		return app.windows.firstMatch
	}
}

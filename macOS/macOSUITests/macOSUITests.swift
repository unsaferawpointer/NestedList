//
//  macOSUITests.swift
//  macOSUITests
//
//  Created by Anton Cherkasov on 26.01.2025.
//

import XCTest

final class macOSUITests: XCTestCase {

	var app: AppPage!

	override func setUpWithError() throws {
		continueAfterFailure = false
		app = AppPage(app: XCUIApplication())
		app.launch(with: ["onboarding_version": "999.0.0"])
		app.closeAll()
		_ = app.waitUntilNoWindows()
	}

	override func tearDownWithError() throws {
		app.closeAll()
		app.app.terminate()
		app = nil
	}
}

// MARK: - Common cases
extension macOSUITests {

	func test_createNewAnyTimes() {
		// Arrange
		let app = prepareApp()

		// Act
		for _ in 0..<3 {
			app.press("n", modifierFlags: .command)
		}

		// Assert
		XCTAssertEqual(app.windows().count, 3)
	}

	func test_createNew() {
		// Arrange
		let app = prepareApp()

		// Act
		app.press("n", modifierFlags: .command)

		let window = app.firstWindow()
		let doc = DocumentPage(window: window)

		// Assert
		XCTAssertTrue(doc.checkTitle("Untitled"))
	}

	func test_open() {
		// Arrange
		let app = prepareApp()

		// Act
		app.press("o", modifierFlags: .command)

		// Assert
		XCTAssertTrue(app.windows()["open-panel"].exists)
	}

	func test_save_whenDocumentIsNew() {
		// Arrange
		let app = prepareApp()
		app.newDoc()

		let window = app.firstWindow()
		let doc = DocumentPage(window: window)

		// Act
		app.press("s", modifierFlags: .command)

		XCTAssertTrue(doc.savePanelExists())
		doc.clickSavePanelCancleButton()
	}

	func test_saveAs() {
		// Arrange
		let app = prepareApp()
		app.newDoc()

		let window = app.firstWindow()
		let doc = DocumentPage(window: window)

		// Act
		app.press("s", modifierFlags: [.option, .command, .shift])

		XCTAssertTrue(doc.savePanelExists())
		doc.clickSavePanelCancleButton()
	}

	func test_close() {
		// Arrange
		let app = prepareApp()
		app.newDoc()

		app.press("w", modifierFlags: .command)

		XCTAssertFalse(app.firstWindow().exists)
	}
}

// MARK: - Helpers
private extension macOSUITests {

	func prepareApp() -> AppPage {
		return app
	}
}

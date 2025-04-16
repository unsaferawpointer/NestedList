//
//  macOSUITests.swift
//  macOSUITests
//
//  Created by Anton Cherkasov on 26.01.2025.
//

import XCTest

final class macOSUITests: XCTestCase {

	override func setUpWithError() throws {
		continueAfterFailure = false
	}

	override func tearDownWithError() throws { }
}

// MARK: - Common cases
extension macOSUITests {

	func test_createNewAnyTimes() {
		// Arrange
		let app = AppPage(app: XCUIApplication())
		app.launch()
		app.closeAll()

		// Act
		for _ in 0..<3 {
			app.press("n", modifierFlags: .command)
		}

		// Assert
		XCTAssertEqual(app.windows().count, 3)
	}

	func test_createNew() {
		// Arrange
		let app = AppPage(app: XCUIApplication())
		app.launch()
		app.closeAll()

		// Act
		app.newDoc()

		let window = app.firstWindow()
		let doc = DocumentPage(window: window)

		// Assert
		XCTAssertTrue(doc.checkTitle("Untitled"))
	}

	func test_open() {
		// Arrange
		let app = AppPage(app: XCUIApplication())
		app.launch()
		app.closeAll()

		// Act
		app.press("o", modifierFlags: .command)

		// Assert
		XCTAssertTrue(app.windows()["open-panel"].exists)
	}

	func test_save_whenDocumentIsNew() {
		// Arrange
		let app = prepareApp()

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

		app.press("w", modifierFlags: .command)

		XCTAssertFalse(app.firstWindow().exists)
	}
}

// MARK: - Helpers
private extension macOSUITests {

	func prepareApp() -> AppPage {
		let app = AppPage(app: XCUIApplication())

		app.launch()
		app.closeAll()

		app.newDoc()

		return app
	}
}

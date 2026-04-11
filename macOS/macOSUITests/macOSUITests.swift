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

// MARK: - Test context menu
extension macOSUITests {

	func test_contextMenu_whenDocumentIsEmpty() {
		// Arrange
		let app = prepareApp()
		app.newDoc()

		let window = app.firstWindow()
		let doc = DocumentPage(window: window)

		// Act
		doc.rightClick(nil)

		// Assert
		doc.checkMenuItem(with: "newItem-menu-item", title: "New Item", isEnabled: true)
		doc.checkMenuItem(with: "edit-menu-item", title: "Edit…", isEnabled: false)
		doc.checkMenuItem(with: "strikethrough-menu-item", title: "Strikethrough", isEnabled: false)
		doc.checkMenuItem(with: "note-menu-item", title: "Note", isEnabled: false)
		doc.checkMenuItem(with: "icon-menu-item", title: "Icon…", isEnabled: false)
		doc.checkMenuItem(with: "delete-menu-item", title: "Delete", isEnabled: false)

	}

	func test_contextMenu_whenDocumentIsNotEmpty() {
		// Arrange
		let app = prepareApp()
		app.newDoc()

		let window = app.firstWindow()
		let doc = DocumentPage(window: window)

		// Act
		for _ in 0..<3 {
			app.press("t", modifierFlags: .command)
		}
		doc.rightClick(0)

		// Assert
		doc.checkMenuItem(with: "newItem-menu-item", title: "New Item", isEnabled: true)
		doc.checkMenuItem(with: "edit-menu-item", title: "Edit…", isEnabled: true)
		doc.checkMenuItem(with: "strikethrough-menu-item", title: "Strikethrough", isEnabled: true)
		doc.checkMenuItem(with: "note-menu-item", title: "Note", isEnabled: true)
		doc.checkMenuItem(with: "icon-menu-item", title: "Icon…", isEnabled: true)
		doc.checkMenuItem(with: "delete-menu-item", title: "Delete", isEnabled: true)
	}
}

// MARK: - Helpers
private extension macOSUITests {

	func prepareApp() -> AppPage {
		return app
	}
}

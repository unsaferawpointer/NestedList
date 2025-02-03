//
//  DocumentPage.swift
//  iOSUITests
//
//  Created by Anton Cherkasov on 03.02.2025.
//

import XCTest

final class DocumentPage {

	let window: XCUIElement

	// MARK: - Initialization

	init(window: XCUIElement) {
		self.window = window
	}
}

// MARK: - Public interface
extension DocumentPage {

	func createDocument() {
		window.buttons["Create Document"].tap()
	}

	func tapAddButton() {
		let button = window.buttons.matching(identifier: "navigation-item-add").firstMatch
		if button.waitForExistence(timeout: 1) {
			button.tap()
		} else {
			XCTFail("Can`t find button")
		}
	}

	func contextMenu(for row: Int) {
		let table = window.tables.firstMatch
		guard table.waitForExistence(timeout: 0.1) else {
			return XCTFail("Can`t find table")
		}
		let cell = table.cells.element(boundBy: row)
		guard cell.waitForExistence(timeout: 0.1) else {
			return XCTFail("Can`t find row")
		}
		cell.press(forDuration: 0.5)
	}

	func tap(menuItem id: String) {
		let button = window.buttons.matching(identifier: id).firstMatch
		if button.waitForExistence(timeout: 1) {
			button.tap()
		} else {
			XCTFail("Can`t find button")
		}
	}

	func text(for row: Int) -> String? {
		let staticText = cell(for: row)?.staticTexts.element(boundBy: 0)
		return staticText?.label
	}

	func detail(for row: Int) -> String? {
		let staticText = cell(for: row)?.staticTexts.element(boundBy: 1)
		return staticText?.label
	}
}

// MARK: - Helpers
private extension DocumentPage {

	func cell(for row: Int) -> XCUIElement? {
		let table = window.tables.firstMatch
		guard table.waitForExistence(timeout: 0.1) else {
			XCTFail("Can`t find table")
			return nil
		}
		return table.cells.element(boundBy: row)
	}
}

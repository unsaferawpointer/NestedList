//
//  DetailsPage.swift
//  iOSUITests
//
//  Created by Anton Cherkasov on 03.02.2025.
//

import XCTest

final class DetailsPage {

	let window: XCUIElement

	// MARK: - Initialization

	init(window: XCUIElement) {
		self.window = window
	}
}

// MARK: - Public interface
extension DetailsPage {

	func hintExists() -> Bool {
		window.staticTexts.matching(identifier: "label-hint").count > 0
	}

	func enterTitle(_ title: String) {
		let textfield = window.textFields.matching(identifier: "textfield-title").firstMatch
		if textfield.waitForExistence(timeout: 1) {
			textfield.typeText(title)
		} else {
			XCTFail(#function)
		}
	}

	func enterDescription(_ description: String) {
		let textfield = window.textViews.matching(identifier: "textfield-description").firstMatch
		if textfield.waitForExistence(timeout: 1) {
			textfield.tap()
			textfield.typeText(description)
		} else {
			XCTFail(#function)
		}
	}

	func tapSaveButton() {
		let button = window.buttons.matching(identifier: "button-save").firstMatch
		if button.waitForExistence(timeout: 1) {
			button.tap()
		} else {
			XCTFail(#function)
		}
	}
}

//
//  AppPage.swift
//  macOSUITests
//
//  Created by Anton Cherkasov on 13.04.2025.
//

import XCTest

final class AppPage {

	var app: XCUIApplication

	init(app: XCUIApplication) {
		self.app = app
	}
}

// MARK: - Public Interface
extension AppPage {

	func launch() {
		app.launch()
	}

	func newDoc() {
		app.typeKey("n", modifierFlags: .command)
	}

	func firstWindow() -> XCUIElement {
		return app.windows.firstMatch
	}

	func windows() -> XCUIElementQuery {
		return app.windows
	}

	func closeAll() {
		while !app.windows.allElementsBoundByIndex.isEmpty {
			for window in app.windows.allElementsBoundByIndex.reversed() {
				DocumentPage(window: window).close()
			}
		}
	}

	func press(_ key: String, modifierFlags: XCUIElement.KeyModifierFlags) {
		app.typeKey(key, modifierFlags: modifierFlags)
	}
}

//
//  AppPage.swift
//  macOSUITests
//
//  Created by Anton Cherkasov on 13.04.2025.
//

import XCTest
import Foundation

final class AppPage {

	var app: XCUIApplication

	init(app: XCUIApplication) {
		self.app = app
	}
}

// MARK: - Public Interface
extension AppPage {

	func launch(with defaults: [String: String] = [:]) {
		app.launchArguments.append("--UITesting")
		for (key, value) in defaults {
			app.launchEnvironment[key] = value
		}
		app.launch()
		app.activate()
	}

	func newDoc() {
		let expectedCount = app.windows.count + 1
		if !selectFileMenuItem("New") {
			press("n", modifierFlags: .command)
		}
		if waitForWindowsCount(atLeast: expectedCount) {
			return
		}
		press("n", modifierFlags: .command)
		_ = waitForWindowsCount(atLeast: expectedCount)
	}

	func openDoc() {
		if !selectFileMenuItem("Open…") {
			press("o", modifierFlags: .command)
		}
	}

	func saveDoc() {
		if !selectFileMenuItem("Save…") {
			press("s", modifierFlags: .command)
		}
	}

	func saveAsDoc() {
		press("s", modifierFlags: [.command, .shift])
	}

	func closeDoc() {
		if !selectFileMenuItem("Close") {
			press("w", modifierFlags: .command)
		}
	}

	func onboarding() -> XCUIElement {
		return app.dialogs["onboarding-window"].firstMatch
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
		app.activate()
		app.typeKey(key, modifierFlags: modifierFlags)
	}

	func hasOpenPanel() -> Bool {
		if app.windows["open-panel"].waitForExistence(timeout: 0.5) {
			return true
		}
		if app.dialogs.firstMatch.waitForExistence(timeout: 0.5) {
			return true
		}
		return app.sheets.firstMatch.waitForExistence(timeout: 0.5)
	}

	func waitUntilNoWindows() -> Bool {
		let predicate = NSPredicate(format: "count == 0")
		let expectation = XCTNSPredicateExpectation(predicate: predicate, object: app.windows)
		return XCTWaiter.wait(for: [expectation], timeout: 4) == .completed
	}
}

// MARK: - Private helpers
private extension AppPage {

	func waitForWindowsCount(atLeast count: Int) -> Bool {
		let predicate = NSPredicate(format: "count >= %d", count)
		let expectation = XCTNSPredicateExpectation(predicate: predicate, object: app.windows)
		return XCTWaiter.wait(for: [expectation], timeout: 2) == .completed
	}

	func selectFileMenuItem(_ title: String) -> Bool {
		let fileMenu = app.menuBars.menuBarItems["File"]
		guard fileMenu.waitForExistence(timeout: 1) else {
			return false
		}
		fileMenu.click()
		let menuItem = app.menuBars.menuItems[title]
		guard menuItem.waitForExistence(timeout: 1) else {
			return false
		}
		menuItem.click()
		return true
	}
}

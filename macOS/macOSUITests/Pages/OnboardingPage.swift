//
//  OnboardingPage.swift
//  macOSUITests
//
//  Created by Anton Cherkasov on 08.05.2025.
//

import XCTest

final class OnboardingPage {

	let window: XCUIElement

	init(window: XCUIElement) {
		_ = window.waitForExistence(timeout: 0.5)
		precondition(window.elementType == .dialog, "It is not dialog")
		precondition(window.identifier == "onboarding-window", "It is not onboarding window")
		self.window = window
	}
}

//
//  GlobalRouter.swift
//  Nested List
//
//  Created by Anton Cherkasov on 26.04.2026.
//

import AppKit
import CoreModule

@MainActor protocol GlobalRouterProtocol {
	func showOnboarding(for version: Version)
	func showPreferences()
	func showOpenPanel(completionHandler: @escaping (URL) -> Void)
}

final class GlobalRouter: NSObject {

	// MARK: - Internal State

	private var preferencesWindowController: NSWindowController?

	private var onboardingWindow: NSWindow?
}

// MARK: - GlobalRouterProtocol
extension GlobalRouter: GlobalRouterProtocol {

	func showOnboarding(for version: Version) {
		guard let window = OnboardingAssembly.build(settingsProvider: .shared, for: version) else {
			return
		}
		self.onboardingWindow = window
		window.center()
		NSApp.runModal(for: window)
	}

	func showPreferences() {
		preferencesWindowController = self.preferencesWindowController ?? PreferencesAssembly.build(
			settingsProvider: .shared
		)

		let window = preferencesWindowController?.window
		window?.delegate = self
		window?.makeKeyAndOrderFront(nil)
		NSApp.activate(ignoringOtherApps: true)
	}

	func showOpenPanel(completionHandler: @escaping (URL) -> Void) {
		let openPanel = NSOpenPanel()
		openPanel.allowedContentTypes = [.plainText]
		openPanel.allowsMultipleSelection = false
		openPanel.begin { result in
			if result == .OK, let url = openPanel.url {
				completionHandler(url)
			}
		}
	}
}

// MARK: - NSWindowDelegate
extension GlobalRouter: NSWindowDelegate {

	func windowWillClose(_ notification: Notification) {
		guard let window = notification.object as? NSWindow else {
			return
		}
		if preferencesWindowController?.window === window {
			preferencesWindowController = nil
		}
		if onboardingWindow === window {
			onboardingWindow = nil
		}
	}
}

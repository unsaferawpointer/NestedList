//
//  AppRouter.swift
//  Nested List
//
//  Created by Anton Cherkasov on 26.04.2026.
//

import AppKit
import SwiftUI
import CoreSettings

final class AppRouter: NSObject {

	// MARK: - Internal State

	private var preferencesWindowController: NSWindowController?

	private var onboardingWindow: NSWindow?
}

extension AppRouter {

	func showPreferences() {
		let id = NSUserInterfaceItemIdentifier("dev.zeroindex.NestedList.settings-window")

		let window: NSWindow
		if let existingWindow = preferencesWindowController?.window {
			window = existingWindow
		} else {
			let viewController = NSHostingController(rootView: SettingsView(provider: .shared))
			let newWindow = NSWindow(contentViewController: viewController)
			newWindow.identifier = id
			newWindow.title = "Settings"
			newWindow.delegate = self

			let windowController = NSWindowController(window: newWindow)
			preferencesWindowController = windowController
			window = newWindow
		}

		window.makeKeyAndOrderFront(nil)
		NSApp.activate(ignoringOtherApps: true)
	}

	func showOnboardingIfNeeded() {

		#if DEBUG
		if CommandLine.arguments.contains("--UITesting") {
			guard let rawVersion = ProcessInfo.processInfo.environment["onboarding_version"] else {
				SettingsProvider.shared.state.lastOnboardingVersion = nil
				return
			}
			SettingsProvider.shared.state.lastOnboardingVersion = .init(rawValue: rawVersion)
		}
		#endif

		guard let window = OnboardingAssembly.build(settingsProvider: .shared) else {
			return
		}
		self.onboardingWindow = window
		window.center()
		NSApp.runModal(for: window)
	}
}

// MARK: - NSWindowDelegate
extension AppRouter: NSWindowDelegate {

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

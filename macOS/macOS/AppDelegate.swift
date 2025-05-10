//
//  AppDelegate.swift
//  macOS
//
//  Created by Anton Cherkasov on 16.11.2024.
//

import Cocoa
import DesignSystem

@main
class AppDelegate: NSObject, NSApplicationDelegate {

	var onboardingWindow: NSWindow?

	var importCoordinator: ImportCoordinator?

	func applicationDidFinishLaunching(_ aNotification: Notification) {
		prepareMenu()
		showOnboardingIfNeeded()
	}

	func applicationWillTerminate(_ aNotification: Notification) {
		// Insert code here to tear down your application
	}

	func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
		return true
	}
}

// MARK: - Helpers
private extension AppDelegate {

	func prepareMenu() {
		if let menu = NSApplication.shared.mainMenu {

			let item = NSMenuItem()
			item.title = "Editor"
			item.submenu = MenuBuilder.build()

			menu.insertItem(item, at: 3)
		}
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

import SwiftUI
import CoreModule
import CoreSettings

// MARK: - Actions
extension AppDelegate {

	// MARK: - Импорт файла
	@IBAction func importFile(_ sender: Any) {
		importCoordinator = ImportCoordinator()
		importCoordinator?.start()
	}

	@IBAction
	func showPreferences(_ sender: Any) {

		let id = NSUserInterfaceItemIdentifier("dev.zeroindex.NestedList.settings-window")

		let window = {
			if let window = NSApp.windows.first(where: { $0.identifier == id }) {
				return window
			} else {
				let viewController = NSHostingController(rootView: SettingsView(provider: .shared))
				let window = NSWindow(contentViewController: viewController)
				window.identifier = id
				window.title = "Settings"
				_ = NSWindowController(window: window)
				return window
			}
		}()

		window.center()
		window.makeKeyAndOrderFront(nil)
		NSApp.activate(ignoringOtherApps: true)
	}
}

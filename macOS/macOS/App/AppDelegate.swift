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
	private let appRouter = AppRouter()

	var importCoordinator: ImportCoordinator?

	func applicationDidFinishLaunching(_ aNotification: Notification) {
		prepareMenu()
		showOnboardingIfNeeded()
	}

	func applicationWillTerminate(_ aNotification: Notification) {
		// Insert code here to tear down your application
	}

	func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
		#if DEBUG
		if CommandLine.arguments.contains("--UITesting") {
			return false
		}
		#endif
		return true
	}
}

// MARK: - Helpers
private extension AppDelegate {

	@MainActor
	func prepareMenu() {
		if let menu = NSApplication.shared.mainMenu {

			let item = NSMenuItem()
			item.title = "Editor"
			item.submenu = MenuBuilder.build(
				for: [.newItem,
					  .separator,
				   .completed,
				   .separator,
				   .icon, .color,
				   .separator,
				   .delete],
				target: nil
			)

			menu.insertItem(item, at: 3)
		}
	}

	func showOnboardingIfNeeded() {
		appRouter.showOnboardingIfNeeded()
	}
}

import SwiftUI
import CoreModule

// MARK: - Actions
extension AppDelegate {

	@IBAction
	func importFile(_ sender: Any) {
		importCoordinator = ImportCoordinator()
		importCoordinator?.start()
	}

	@IBAction
	func showPreferences(_ sender: Any) {
		appRouter.showPreferences()
	}
}

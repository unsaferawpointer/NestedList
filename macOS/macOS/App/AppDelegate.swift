//
//  AppDelegate.swift
//  macOS
//
//  Created by Anton Cherkasov on 16.11.2024.
//

import Cocoa
import DesignSystem

@main
class AppDelegate: NSObject {
	@MainActor private var coordinator = ClobalCoordinator()
}

// MARK: - NSApplicationDelegate
extension AppDelegate: NSApplicationDelegate {

	func applicationDidFinishLaunching(_ aNotification: Notification) {
		prepareMenu()
		coordinator.start()
	}

	func applicationWillTerminate(_ aNotification: Notification) { }

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
}

// MARK: - Actions
extension AppDelegate {

	@IBAction
	func importFile(_ sender: Any) {
		coordinator.importFile()
	}

	@IBAction
	func showPreferences(_ sender: Any) {
		coordinator.showPreferences()
	}
}

//
//  AppDelegate.swift
//  macOS
//
//  Created by Anton Cherkasov on 16.11.2024.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {

	func applicationDidFinishLaunching(_ aNotification: Notification) {
		if let menu = NSApplication.shared.mainMenu {

			let item = NSMenuItem()
			item.title = "Editor"
			item.submenu = MenuBuilder.build()

			menu.insertItem(item, at: 2)
		}
	}

	func applicationWillTerminate(_ aNotification: Notification) {
		// Insert code here to tear down your application
	}

	func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
		return true
	}

}

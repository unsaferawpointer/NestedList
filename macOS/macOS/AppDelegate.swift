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
		guard let window = OnboardingAssembly.build(settingsProvider: .shared) else {
			return
		}
		self.onboardingWindow = window
		window.center()
		NSApp.runModal(for: window)
	}

	private func loadFile(at url: URL) {
		do {

			let document = Document()
			try document.read(from: url, ofType: DocumentType.text.rawValue)
			document.updateChangeCount(.changeReadOtherContents)

			document.fileURL = nil

			NSDocumentController.shared.addDocument(document)
			document.makeWindowControllers()
			document.showWindows()

		} catch {
			NSApp.presentError(error)
		}
	}
}

import SwiftUI
import CoreModule
import CoreSettings

// MARK: - Actions
extension AppDelegate {

	// MARK: - Импорт файла
	@IBAction func importFile(_ sender: Any) {
		let openPanel = NSOpenPanel()
		openPanel.allowedContentTypes = [.plainText]
		openPanel.allowsMultipleSelection = false

		openPanel.begin { [weak self] (result) in
			if result == .OK, let url = openPanel.url {
				self?.loadFile(at: url)
			}
		}
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

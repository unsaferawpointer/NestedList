//
//  PreferencesAssembly.swift
//  Nested List
//
//  Created by Anton Cherkasov on 07.05.2026.
//

import AppKit
import SwiftUI
import CorePresentation

final class PreferencesAssembly {

	static func build(settingsProvider: SettingsProvider) -> NSWindowController? {
		let identifier = "dev.zeroindex.NestedList.settings-window"
		let viewController = NSHostingController(
			rootView: SettingsView(provider: settingsProvider)
		)
		let newWindow = NSWindow(contentViewController: viewController)
		newWindow.identifier = NSUserInterfaceItemIdentifier(identifier)
		newWindow.title = String(localized: "window-title", table: "PreferencesLocalizable")

		return NSWindowController(window: newWindow)
	}
}

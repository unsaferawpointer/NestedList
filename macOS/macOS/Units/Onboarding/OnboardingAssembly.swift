//
//  OnboardingAssembly.swift
//  Nested List
//
//  Created by Anton Cherkasov on 01.05.2025.
//

import AppKit
import SwiftUI
import CoreSettings
import CoreModule
import DesignSystem

final class OnboardingAssembly {

	static func build(settingsProvider: SettingsProvider) -> NSWindow? {

		// Версия приложения (например: "1.2.0")
		if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
			print("appVersion = \(appVersion)")

			let window = NSWindow()

			let view = OnboardingView(pages: [.newFormat, .customization]) {
				settingsProvider.state.lastOnboardingVersion = .init(rawValue: "appVersion")

				// Правильное закрытие
				guard NSApp.modalWindow === window && NSApp.modalWindow?.isVisible ?? false else {
					return
				}

				NSApp.stopModal()
				window.close()
			}

			window.styleMask = [.closable, .resizable, .titled, .fullSizeContentView]
			window.titleVisibility = .hidden
			window.toolbar?.isVisible = false
			window.isOpaque = true
			window.titlebarAppearsTransparent = true
			window.contentViewController = NSHostingController(rootView: view)

			return window
		}

		return nil
	}
}

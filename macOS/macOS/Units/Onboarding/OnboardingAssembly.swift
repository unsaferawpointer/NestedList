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
		guard
			let rawVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
			let appVersion = Version(rawValue: rawVersion)
		else {
			return nil
		}

		guard let lastOnboardingVersion = settingsProvider.state.lastOnboardingVersion?.version else {
			return buildWindow(settingsProvider: settingsProvider, appVersion: rawVersion)
		}

		guard lastOnboardingVersion < appVersion else {
			return nil
		}

		return buildWindow(settingsProvider: settingsProvider, appVersion: rawVersion)
	}
}

// MARK: - Helpers
private extension OnboardingAssembly {

	static func buildWindow(settingsProvider: SettingsProvider, appVersion: String) -> NSWindow {
		let window = NSWindow()

		let view = OnboardingView(pages: [.newFormat, .customization]) {
			settingsProvider.state.lastOnboardingVersion = .init(rawValue: appVersion)

			guard NSApp.modalWindow === window && NSApp.modalWindow?.isVisible ?? false else {
				return
			}

			NSApp.stopModal()
			window.close()
		}

		window.styleMask = [.fullSizeContentView, .titled]
		window.titleVisibility = .hidden
		window.toolbar?.isVisible = false
		window.isOpaque = true
		window.titlebarAppearsTransparent = true
		window.contentViewController = NSHostingController(rootView: view)

		return window
	}
}

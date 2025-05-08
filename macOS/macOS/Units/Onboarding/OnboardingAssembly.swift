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
			return buildWindow(settingsProvider: settingsProvider, version: appVersion)
		}

		guard lastOnboardingVersion < appVersion else {
			return nil
		}

		return buildWindow(settingsProvider: settingsProvider, version: appVersion)
	}
}

// MARK: - Helpers
private extension OnboardingAssembly {

	static func buildWindow(settingsProvider: SettingsProvider, version: Version) -> NSWindow? {

		let window = NSWindow()

		guard let pages = try? OnboardingFactory.build(for: version) else {
			return nil
		}
		let view = OnboardingView(pages: pages) {
			settingsProvider.state.lastOnboardingVersion = .init(rawValue: version.rawValue)

			guard NSApp.modalWindow === window && NSApp.modalWindow?.isVisible ?? false else {
				return
			}

			NSApp.stopModal()
			window.close()
		}

		window.styleMask = [.fullSizeContentView, .titled, .resizable]
		window.titleVisibility = .hidden
		window.toolbar?.isVisible = false
		window.isOpaque = true
		window.titlebarAppearsTransparent = true

		let contentViewController = NSHostingController(rootView: view)
		window.contentViewController = contentViewController

		window.setContentSize(contentViewController.view.fittingSize)

		return window
	}
}

//
//  OnboardingAssembly.swift
//  Nested List
//
//  Created by Anton Cherkasov on 01.05.2025.
//

import AppKit
import SwiftUI
import CoreModule
import DesignSystem
import CorePresentation

final class OnboardingAssembly {

	static func build(settingsProvider: SettingsProvider, for version: Version) -> NSWindow? {
		return buildWindow(settingsProvider: settingsProvider, version: version)
	}
}

// MARK: - Helpers
private extension OnboardingAssembly {

	static func buildWindow(settingsProvider: SettingsProvider, version: Version) -> NSWindow? {

		let window = NSWindow()
		window.identifier = .init("onboarding-window")

		guard let features = try? OnboardingFactory.build(for: version, in: .main), !features.isEmpty else {
			return nil
		}
		let view = OnboardingView(features: features) {
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

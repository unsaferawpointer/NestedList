//
//  OnboardingAssembly.swift
//  Nested List
//
//  Created by Anton Cherkasov on 01.05.2025.
//

import AppKit
import SwiftUI
import CoreModule
import CorePresentation

@MainActor final class OnboardingAssembly {

	static func build(settingsProvider: SettingsProvider, for version: Version) -> NSWindow? {
		return buildWindow(settingsProvider: settingsProvider, version: version)
	}
}

// MARK: - Helpers
private extension OnboardingAssembly {

	static func buildWindow(settingsProvider: SettingsProvider, version: Version) -> NSWindow? {

		let window = NSWindow()
		window.identifier = .init("onboarding-window")

		let features = OnboardingFactory.build()
		guard !features.isEmpty else {
			return nil
		}
		let view = OnboardingContent(features: features) {
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

@MainActor private struct OnboardingContent {

	@State private var isApplicationActive = NSApp.isActive

	let features: [Onboarding.Feature]
	let onComplete: @MainActor () -> Void
}

// MARK: - View
extension OnboardingContent: View {

	var body: some View {
		OnboardingView(features: features, onComplete: onComplete)
			.environment(\.scenePhase, isApplicationActive ? .active : .inactive)
			.onAppear {
				isApplicationActive = NSApp.isActive
			}
			.onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in
				isApplicationActive = true
			}
			.onReceive(NotificationCenter.default.publisher(for: NSApplication.didResignActiveNotification)) { _ in
				isApplicationActive = false
			}
	}
}

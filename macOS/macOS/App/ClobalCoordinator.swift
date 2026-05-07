//
//  ClobalCoordinator.swift
//  Nested List
//
//  Created by Anton Cherkasov on 05.05.2026.
//

import Foundation
import AppKit
import CoreModule
import CorePresentation

@MainActor final class ClobalCoordinator {

	let settingsProvider: any StateProviderProtocol<CorePresentation.Settings>

	let infoProvider: InfoProvider

	let router: GlobalRouterProtocol

	let documentController: DocumentControllerProtocol

	// MARK: - Initialization

	init(
		settingsProvider: any StateProviderProtocol<CorePresentation.Settings> = SettingsProvider.shared,
		infoProvider: InfoProvider = AppInfo(),
		router: GlobalRouterProtocol = GlobalRouter(),
		documentController: DocumentControllerProtocol = DocumentController()
	) {
		self.settingsProvider = settingsProvider
		self.infoProvider = infoProvider
		self.router = router
		self.documentController = documentController
	}

}

// MARK: - Public Interface
extension ClobalCoordinator {

	func start() {
		#if DEBUG
		prepareForUITesting()
		#endif
		if shouldShowOnboarding, let version = infoProvider.version {
			router.showOnboarding(for: version)
		}
	}

	func importFile() {
		router.showOpenPanel { [weak self] url in
			self?.loadFile(at: url)
		}
	}

	func showPreferences() {
		router.showPreferences()
	}
}

// MARK: - Helpers
private extension ClobalCoordinator {

	var shouldShowOnboarding: Bool {
		let lastVersion = settingsProvider.state.lastOnboardingVersion?.version
		guard let lastVersion else {
			return true
		}
		guard let appVersion = infoProvider.version else {
			return false
		}
		return lastVersion < appVersion
	}

	func loadFile(at url: URL) {
		documentController.loadFile(at: url, with: .plainText)
	}

	func prepareForUITesting() {
		if CommandLine.arguments.contains("--UITesting") {
			guard let rawVersion = ProcessInfo.processInfo.environment["onboarding_version"] else {
				SettingsProvider.shared.state.lastOnboardingVersion = nil
				return
		}
			SettingsProvider.shared.state.lastOnboardingVersion = .init(rawValue: rawVersion)
		}
	}
}

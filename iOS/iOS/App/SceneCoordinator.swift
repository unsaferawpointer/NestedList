//
//  SceneCoordinator.swift
//  iOS
//
//  Created by Anton Cherkasov on 09.05.2026.
//

import UIKit
import CoreModule
import CorePresentation

final class SceneCoordinator {

	// MARK: - DI by initialization

	private let router: SceneRouter

	let infoProvider: InfoProvider

	let settingsProvider: any StateProviderProtocol<Settings>

	// MARK: - Initialization

	init(
		router: SceneRouter = SceneRouter(),
		infoProvider: InfoProvider = AppInfo(),
		settingsProvider: any StateProviderProtocol<Settings> = SettingsProvider.shared
	) {
		self.router = router
		self.infoProvider = infoProvider
		self.settingsProvider = settingsProvider
	}
}

// MARK: - Public Interface
extension SceneCoordinator {

	func start(for scene: UIScene, options connectionOptions: UIScene.ConnectionOptions) {
		router.showWindow(for: scene, options: connectionOptions)
		if shouldShowOnboarding, let version = infoProvider.version {
			router.showOnboarding(for: version, settingsProvider: SettingsProvider.shared)
		}
	}

	func handleDocument(url: URL) {
		router.handleDocument(url: url)
	}
}

// MARK: - Helpers
private extension SceneCoordinator {

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
}

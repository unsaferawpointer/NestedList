//
//  OnboardingAssembly.swift
//  iOS
//
//  Created by Anton Cherkasov on 01.05.2025.
//

import UIKit
import SwiftUI
import CoreModule
import DesignSystem
import CorePresentation

final class OnboardingAssembly {

	static func build(settingsProvider: SettingsProvider) -> UIViewController? {
		guard let appVersion = AppInfo().version else {
			return nil
		}

		guard let lastOnboardingVersion = settingsProvider.state.lastOnboardingVersion?.version else {
			return buildViewController(settingsProvider: settingsProvider, version: appVersion)
		}

		guard lastOnboardingVersion < appVersion else {
			return nil
		}

		return buildViewController(settingsProvider: settingsProvider, version: appVersion)
	}
}

// MARK: - Helpers
private extension OnboardingAssembly {

	static func buildViewController(settingsProvider: SettingsProvider, version: Version) -> UIViewController? {
		guard let pages = try? OnboardingFactory.build(for: version) else {
			return nil
		}
		let view = OnboardingView(pages: pages) {
			settingsProvider.state.lastOnboardingVersion = .init(rawValue: version.rawValue)
		}
		return UIHostingController(rootView: view)
	}
}


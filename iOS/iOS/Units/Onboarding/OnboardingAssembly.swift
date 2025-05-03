//
//  OnboardingAssembly.swift
//  iOS
//
//  Created by Anton Cherkasov on 01.05.2025.
//

import UIKit
import SwiftUI
import CoreSettings
import CoreModule
import DesignSystem

final class OnboardingAssembly {

	static func build(settingsProvider: SettingsProvider) -> UIViewController? {
		guard
			let rawVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
			let appVersion = Version(rawValue: rawVersion)
		else {
			return nil
		}

		guard let lastOnboardingVersion = settingsProvider.state.lastOnboardingVersion?.version else {
			return buildViewController(settingsProvider: settingsProvider, appVersion: rawVersion)
		}

		guard lastOnboardingVersion < appVersion else {
			return nil
		}

		return buildViewController(settingsProvider: settingsProvider, appVersion: rawVersion)
	}
}

// MARK: - Helpers
private extension OnboardingAssembly {

	static func buildViewController(settingsProvider: SettingsProvider, appVersion: String) -> UIViewController {
		let view = OnboardingView(pages: [.newFormat, .customization]) {
			settingsProvider.state.lastOnboardingVersion = .init(rawValue: appVersion)
		}
		return UIHostingController(rootView: view)
	}
}


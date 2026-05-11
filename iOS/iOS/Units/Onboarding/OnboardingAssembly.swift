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

	static func build(
		settingsProvider: any StateProviderProtocol<Settings>,
		for version: Version
	) -> UIViewController? {
		return buildViewController(settingsProvider: settingsProvider, version: version)
	}
}

// MARK: - Helpers
private extension OnboardingAssembly {

	static func buildViewController(
		settingsProvider: any StateProviderProtocol<Settings>,
		version: Version
	) -> UIViewController? {
		guard let features = try? OnboardingFactory.build(for: version) else {
			return nil
		}
		let view = OnboardingView(features: features) {
			settingsProvider.state.lastOnboardingVersion = .init(rawValue: version.rawValue)
		}
		return UIHostingController(rootView: view)
	}
}

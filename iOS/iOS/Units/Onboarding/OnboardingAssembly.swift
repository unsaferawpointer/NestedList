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

		// Версия приложения (например: "1.2.0")
		if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
			let view = OnboardingView(pages: [.newFormat, .customization]) {
				settingsProvider.state.lastOnboardingVersion = .init(rawValue: "appVersion")
			}
			return UIHostingController(rootView: view)
		}

		return nil
	}
}


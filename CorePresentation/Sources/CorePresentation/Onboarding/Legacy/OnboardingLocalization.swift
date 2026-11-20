//
//  OnboardingLocalization.swift
//  CorePresentation
//
//  Created by Anton Cherkasov on 03.05.2025.
//

import Foundation

struct OnboardingLocalization {

	static let backButtonTitle =
		String(
			localized: "onboarding-back-button-title",
			table: "Localizable",
			bundle: .module
		)

	static let nextButtonTitle =
		String(
			localized: "onboarding-next-button-title",
			table: "Localizable",
			bundle: .module
		)

	static let getStaredButtonTitle =
		String(
			localized: "onboarding-get-started-button-title",
			table: "Localizable",
			bundle: .module
		)

	static let skipButtonTitle =
		String(
			localized: "onboarding-skip-button-title",
			table: "Localizable",
			bundle: .module
		)
}

// MARK: - Page content
extension OnboardingLocalization {

	static let subitemsTitle = String(localized: "onboarding-subitems-title", table: "OnboardingLocalizable", bundle: .module)

	static let subitemsSubtitle = String(localized: "onboarding-subitems-subtitle", table: "OnboardingLocalizable", bundle: .module)

	static let customizationTitle = String(localized: "onboarding-customization-title", table: "OnboardingLocalizable", bundle: .module)

	static let customizationSubtitle = String(localized: "onboarding-customization-subtitle", table: "OnboardingLocalizable", bundle: .module)

	static let mirrorsTitle = String(localized: "onboarding-mirrors-title", table: "OnboardingLocalizable", bundle: .module)

	static let mirrorsSubtitle = String(localized: "onboarding-mirrors-subtitle", table: "OnboardingLocalizable", bundle: .module)
}

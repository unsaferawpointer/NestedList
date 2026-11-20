//
//  Onboarding+Feature.swift
//  CorePresentation
//
//  Created by Anton Cherkasov on 01.05.2025.
//

import Foundation

// MARK: - Nested data structs
public extension Onboarding {

	@MainActor struct Feature {

		public var id: String

		let title: String
		let subtitle: String
		let scenario: OnboardingScenario

		// MARK: - Initialization

		public init(
			id: String = UUID().uuidString,
			title: String,
			subtitle: String,
			scenario: Scenario
		) {
			self.id = id
			self.title = title
			self.subtitle = subtitle
			self.scenario = scenario.makeScenario()
		}
	}
}

// MARK: - Identifiable
extension Onboarding.Feature: Identifiable { }

// MARK: - Nested data structs
public extension Onboarding.Feature {

	enum Scenario {
		case subitems
		case customization
		case mirrors
	}
}

// MARK: - Private methods
private extension Onboarding.Feature.Scenario {

	@MainActor func makeScenario() -> OnboardingScenario {
		switch self {
		case .subitems:
			Onboarding.makeSubitemsScenario()
		case .customization:
			Onboarding.makeCustomizationScenario()
		case .mirrors:
			Onboarding.makeMirrorsScenario()
		}
	}
}

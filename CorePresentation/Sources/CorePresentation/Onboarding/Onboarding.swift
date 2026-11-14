//
//  Onboarding.swift
//  CorePresentation
//
//  Created by Anton Cherkasov on 11.11.2026.
//

@MainActor enum Onboarding { }

// MARK: - Item creation
extension Onboarding {

	static func makeItems() -> [OnboardingItem] {
		[
			OnboardingItemBuilder(title: .init(value: "Projects", style: .headline))
				.icon(.init(name: .squareStack, token: .primary))
				.state(.expanded),
			OnboardingItemBuilder(title: .init(value: "App Update", style: .headline))
				.icon(.init(name: .asteriskPoint, token: .primary))
				.state(.expanded)
				.level(1),
			OnboardingItemBuilder(title: "Write release notes")
				.icon(.init(name: .asteriskPoint, token: .primary))
				.level(2),
			OnboardingItemBuilder(title: .init(value: "Test the new version"))
				.icon(.init(name: .asteriskPoint, token: .primary))
				.state(.leaf)
				.level(2),
			OnboardingItemBuilder(title: "Submit the update for review")
				.icon(.init(name: .asteriskPoint, token: .primary))
				.level(2),
			OnboardingItemBuilder(title: "Update screenshots")
				.icon(.init(name: .asteriskPoint, token: .primary))
				.level(2),
			OnboardingItemBuilder(title: "Add frequently asked questions")
				.icon(.init(name: .asteriskPoint, token: .primary))
				.level(2),
			OnboardingItemBuilder(title: .init(value: "App Website", style: .headline))
				.icon(.init(name: .asteriskPoint, token: .primary))
				.state(.expanded)
				.level(1),
			OnboardingItemBuilder(title: .init(value: "Today", style: .headline))
				.icon(.init(name: .calendar, token: .red))
				.state(.expanded),
			OnboardingItemBuilder(title: .init(value: "Test the new version"))
				.icon(.init(name: .asteriskPoint, token: .primary))
				.state(.leaf)
				.icon(.init(name: .linkPoint, token: .primary))
				.level(1),
			OnboardingItemBuilder(title: "Update screenshots")
				.icon(.init(name: .linkPoint, token: .primary))
				.level(1),
			OnboardingItemBuilder(title: "Respond to user feedback")
				.level(1)
		].map { $0.build() }
	}
}

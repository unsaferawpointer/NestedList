import Foundation

@MainActor enum OnboardingItemsFactory { }

// MARK: - Item creation
extension OnboardingItemsFactory {

	static func makeItems() -> [OnboardingItem] {
		[
			OnboardingItemBuilder(title: .init(value: "Projects", style: .headline))
				.icon(.init(name: nil, token: .primary))
				.state(.expanded)
				.build(id: String.projects),
			OnboardingItemBuilder(title: .init(value: "App Update", style: .headline))
				.icon(.init(name: .asteriskPoint, token: .primary))
				.state(.expanded)
				.level(1)
				.build(id: String.appUpdate),
			OnboardingItemBuilder(title: "Write release notes")
				.icon(.init(name: .asteriskPoint, token: .primary))
				.level(2)
				.build(),
			OnboardingItemBuilder(title: .init(value: "Test the new version"))
				.icon(.init(name: .asteriskPoint, token: .primary))
				.state(.leaf)
				.level(2)
				.build(),
			OnboardingItemBuilder(title: "Submit the update for review")
				.icon(.init(name: .asteriskPoint, token: .primary))
				.level(2)
				.build(),
			OnboardingItemBuilder(title: "Update screenshots")
				.icon(.init(name: .asteriskPoint, token: .primary))
				.level(2)
				.build(),
			OnboardingItemBuilder(title: "Add frequently asked questions")
				.icon(.init(name: .asteriskPoint, token: .primary))
				.level(2)
				.build(),
			OnboardingItemBuilder(title: .init(value: "App Website", style: .headline))
				.icon(.init(name: .asteriskPoint, token: .primary))
				.state(.expanded)
				.level(1)
				.build(),
			OnboardingItemBuilder(title: .init(value: "Today", style: .headline))
				.icon(.init(name: nil, token: .primary))
				.state(.expanded)
				.build(id: String.today),
			OnboardingItemBuilder(title: .init(value: "Test the new version"))
				.icon(.init(name: .asteriskPoint, token: .primary))
				.state(.leaf)
				.icon(.init(name: .linkPoint, token: .primary))
				.level(1)
				.build(),
			OnboardingItemBuilder(title: "Update screenshots")
				.icon(.init(name: .linkPoint, token: .primary))
				.level(1)
				.build(),
			OnboardingItemBuilder(title: "Respond to user feedback")
				.level(1)
				.build()
		]
	}
}


public final class OnboardingFactory { }

// MARK: - Public Interface
public extension OnboardingFactory {

	@MainActor static func build() -> [Onboarding.Feature] {
		[
			Onboarding.Feature(
				id: "structured_lists_intro",
				title: OnboardingLocalization.subitemsTitle,
				subtitle: OnboardingLocalization.subitemsSubtitle,
				scenario: .subitems
			),
			Onboarding.Feature(
				id: "customize_items_intro",
				title: OnboardingLocalization.customizationTitle,
				subtitle: OnboardingLocalization.customizationSubtitle,
				scenario: .customization
			),
			Onboarding.Feature(
				id: "mirrors_intro",
				title: OnboardingLocalization.mirrorsTitle,
				subtitle: OnboardingLocalization.mirrorsSubtitle,
				scenario: .mirrors
			)
		]
	}
}

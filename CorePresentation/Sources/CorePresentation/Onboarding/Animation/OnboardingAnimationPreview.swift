import SwiftUI

@MainActor private struct OnboardingAnimationPreview {

	@State private var scenario: OnboardingScenario

	let isActive: Bool

	init(scenario: OnboardingScenario, isActive: Bool = true, showsFinalState: Bool = false) {
		self.isActive = isActive
		let prepared = showsFinalState ? scenario.staticFinalState : scenario
		self._scenario = State(initialValue: prepared)
	}
}

// MARK: - View
extension OnboardingAnimationPreview: View {

	var body: some View {
		OnboardingSceneView(
			scenario: scenario,
			isActive: isActive
		)
			.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
			.environment(\.scenePhase, .active)
	}
}

#Preview("Subitems: add, collapse and expand") {
	OnboardingAnimationPreview(
		scenario: Onboarding.makeSubitemsScenario()
	)
}

#Preview("Item customization") {
	OnboardingAnimationPreview(
		scenario: Onboarding.makeCustomizationScenario()
	)
}

#Preview("Mirrors") {
	OnboardingAnimationPreview(
		scenario: Onboarding.makeMirrorsScenario()
	)
}

#Preview("Reduced motion") {
	// The accessibility environment value is read-only. Preview its static result.
	OnboardingAnimationPreview(
		scenario: Onboarding.makeMirrorsScenario(),
		isActive: false,
		showsFinalState: true
	)
}

#Preview("Inactive scene") {
	OnboardingAnimationPreview(
		scenario: Onboarding.makeSubitemsScenario(),
		isActive: false
	)
}

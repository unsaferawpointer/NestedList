import SwiftUI

@MainActor struct OnboardingPage {

	let title: String
	let subtitle: String
	let scenario: OnboardingScenario
	var isActive = true
}

// MARK: - View
extension OnboardingPage: View {

	var body: some View {
		VStack(spacing: 0) {
			illustration
			textContent
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
	}
}

// MARK: - Private properties
private extension OnboardingPage {

	var illustration: some View {
		OnboardingSceneView(scenario: scenario, isActive: isActive)
			.padding(.horizontal, 24)
			.padding(.top, 24)
			.frame(maxWidth: 420, maxHeight: .infinity)
			.frame(maxWidth: .infinity, maxHeight: .infinity)
			#if os(macOS)
			.background(Color(nsColor: .textBackgroundColor))
			#endif
	}

	var textContent: some View {
		VStack(spacing: 8) {
			Text(title)
				.font(.title.bold())
				.foregroundStyle(.primary)
				.accessibilityAddTraits(.isHeader)

			Text(subtitle)
				.font(.title3)
				.foregroundStyle(.secondary)
		}
		.fixedSize(horizontal: false, vertical: true)
		.multilineTextAlignment(.center)
		.frame(maxWidth: .infinity)
		.padding(.horizontal, 40)
		.padding(.vertical, 24)
		.frame(maxWidth: 640)
		.frame(maxWidth: .infinity)
	}
}

@MainActor private struct OnboardingPagePreview {

	@State private var scenario: OnboardingScenario

	let title: String
	let subtitle: String

	init(title: String, subtitle: String, scenario: OnboardingScenario) {
		self.title = title
		self.subtitle = subtitle
		self._scenario = State(initialValue: scenario)
	}
}

// MARK: - View
extension OnboardingPagePreview: View {

	var body: some View {
		OnboardingPage(title: title, subtitle: subtitle, scenario: scenario)
			.environment(\.scenePhase, .active)
			#if os(macOS)
			.frame(width: 680, height: 540)
			.background(.ultraThickMaterial)
			#endif
	}
}

#Preview("Subitems page") {
	OnboardingPagePreview(
		title: "Organize with subitems",
		subtitle: "Create nested lists and collapse branches to focus on what matters.",
		scenario: Onboarding.makeSubitemsScenario()
	)
}

#Preview("Customization page") {
	OnboardingPagePreview(
		title: "Make every item yours",
		subtitle: "Choose icons and colors, and cross off completed tasks.",
		scenario: Onboarding.makeCustomizationScenario()
	)
}

#Preview("Mirrors page") {
	OnboardingPagePreview(
		title: "Keep items in sync",
		subtitle: "Edit an item in one place and see its mirrors update together.",
		scenario: Onboarding.makeMirrorsScenario()
	)
}

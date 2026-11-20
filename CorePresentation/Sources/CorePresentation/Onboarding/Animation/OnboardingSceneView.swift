import SwiftUI

@MainActor struct OnboardingSceneView {

	let scenario: OnboardingScenario
	var isActive = true
}

// MARK: - View
extension OnboardingSceneView: View {

	var body: some View {
		OnboardingSceneContent(
			scenario: scenario,
			isActive: isActive
		)
			.id(scenario.id)
	}
}

@MainActor private struct OnboardingSceneContent {

	@Environment(\.accessibilityReduceMotion) private var reduceMotion
	@Environment(\.scenePhase) private var scenePhase
	@State private var player: OnboardingPlayer

	let scenario: OnboardingScenario
	let isActive: Bool

	init(scenario: OnboardingScenario, isActive: Bool) {
		self.scenario = scenario
		self.isActive = isActive
		self._player = State(initialValue: OnboardingPlayer(scenario: scenario))
	}
}

// MARK: - View
extension OnboardingSceneContent: View {

	var body: some View {
		List {
			ForEach(reduceMotion ? scenario.final : player.items) { item in
				OnboardingItemView(model: item)
					.listRowBackground(Color.clear)
					.listRowSeparator(.hidden)
					.listRowInsets(
						.init(top: 0, leading: 8, bottom: 0, trailing: 8)
					)
					.transition(.opacity.combined(with: .move(edge: .top)))
			}
		}
		.listStyle(.plain)
		.scrollContentBackground(.hidden)
		.environment(\.defaultMinListRowHeight, 0)
		.allowsHitTesting(false)
		.accessibilityHidden(true)
		.transaction { transaction in
			if reduceMotion {
				transaction.animation = nil
				transaction.disablesAnimations = true
			}
		}
		.task(id: isActive && scenePhase == .active && !reduceMotion) {
			guard isActive, scenePhase == .active, !reduceMotion else {
				return
			}
			await player.run()
		}
	}
}

// MARK: - Animation mapping
extension OnboardingScenario.Transition {

	var animation: Animation {
		let components = duration.components
		let seconds = Double(components.seconds)
			+ Double(components.attoseconds) / 1e18
		return .easeInOut(duration: seconds)
	}
}

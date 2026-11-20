import Observation
import SwiftUI

/// Repeats one prepared scenario until its owning task is cancelled.
@MainActor @Observable
final class OnboardingPlayer {

	private(set) var items: [OnboardingItem]

	private let scenario: OnboardingScenario
	private let sleep: @MainActor (Duration) async throws -> Void

	init(
		scenario: OnboardingScenario,
		sleep: @escaping @MainActor (Duration) async throws -> Void = {
			try await ContinuousClock().sleep(for: $0)
		}
	) {
		self.scenario = scenario
		self.items = scenario.initial
		self.sleep = sleep
	}
}

// MARK: - Playback
extension OnboardingPlayer {

	/// The presentation owns a single task and cancels it before restarting.
	func run() async {
		guard !scenario.steps.isEmpty else {
			return
		}
		do {
			while !Task.isCancelled {
				publish(scenario.initial)
				for step in scenario.steps {
					try Task.checkCancellation()
					let duration = step.duration
					if case let .change(target, transition) = step {
						publish(target, transition: transition)
					}
					if duration > .zero {
						try await sleep(duration)
					}
				}
			}
		} catch {
			// Cancellation leaves the last committed state in place.
		}
	}
}

// MARK: - Private methods
private extension OnboardingPlayer {

	func publish(
		_ items: [OnboardingItem],
		transition: OnboardingScenario.Transition? = nil
	) {
		let transition = transition.flatMap {
			$0.duration > .zero ? $0 : nil
		}
		var transaction = Transaction(
			animation: transition?.animation
		)
		transaction.disablesAnimations = transition == nil
		withTransaction(transaction) {
			self.items = items
		}
	}
}

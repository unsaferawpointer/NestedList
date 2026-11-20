import Foundation

/// A prepared, in-memory demonstration. Retain it for the lifetime of a scene.
/// Changes run once during preparation and must be synchronous and side-effect-free.
/// Preserve IDs for retained rows; hierarchy and descendant visibility are explicit.
struct OnboardingScenario {

	let id: UUID
	let initial: [OnboardingItem]
	let final: [OnboardingItem]
	let steps: [Step]

	init() {
		self.init(snapshot: [])
	}

	init(
		initial: [OnboardingItem],
		@OnboardingScenarioBuilder content: () -> [OnboardingScenarioBuilder.Operation]
	) {
		let operations = content()
		guard Self.validate(initial, step: nil) else {
			self = Self()
			return
		}
		for (index, operation) in operations.enumerated() where operation.duration < .zero {
			assertionFailure("Negative onboarding duration at step \(index)")
			self = Self()
			return
		}
		if !operations.isEmpty,
			!operations.contains(where: { $0.duration > .zero }) {
			assertionFailure("Onboarding scenario must contain a positive-duration step")
			self = Self()
			return
		}

		var items = initial
		var steps: [Step] = []
		for (index, operation) in operations.enumerated() {
			switch operation {
			case let .wait(wait):
				steps.append(.wait(wait.duration))
			case let .change(change):
				change.transform(&items)
				guard Self.validate(items, step: index) else {
					self = Self()
					return
				}
				steps.append(.change(items, .init(duration: change.duration)))
			}
		}
		self.id = UUID()
		self.initial = initial
		self.final = items
		self.steps = steps
	}
}

// MARK: - Static presentation
extension OnboardingScenario {

	var staticFinalState: Self {
		Self(snapshot: final)
	}
}

// MARK: - Private methods
private extension OnboardingScenario {

	init(snapshot: [OnboardingItem]) {
		self.id = UUID()
		self.initial = snapshot
		self.final = snapshot
		self.steps = []
	}

	static func validate(_ items: [OnboardingItem], step: Int?) -> Bool {
		guard Set(items.map(\.id)).count == items.count else {
			let location = step.map { "at step \($0)" } ?? "in initial state"
			assertionFailure("Duplicate onboarding item IDs \(location)")
			return false
		}
		return true
	}
}

// MARK: - Nested data structs
extension OnboardingScenario {

	struct Transition {
		let duration: Duration
	}

	enum Step {

		case wait(Duration)
		case change([OnboardingItem], Transition)

		var duration: Duration {
			switch self {
			case let .wait(value):				value
			case let .change(_, transition):	transition.duration
			}
		}
	}
}

// MARK: - Equatable
extension OnboardingScenario.Transition: Equatable { }

// MARK: - Equatable
extension OnboardingScenario.Step: Equatable { }


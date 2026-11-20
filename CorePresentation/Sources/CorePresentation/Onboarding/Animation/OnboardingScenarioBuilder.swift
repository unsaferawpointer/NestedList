@resultBuilder
enum OnboardingScenarioBuilder { }

// MARK: - Building
extension OnboardingScenarioBuilder {

	static func buildExpression(_ expression: Wait) -> [Operation] {
		[.wait(expression)]
	}

	static func buildExpression(_ expression: Change) -> [Operation] {
		[.change(expression)]
	}

	static func buildExpression(_ operations: [Operation]) -> [Operation] {
		operations
	}

	static func buildBlock(_ components: [Operation]...) -> [Operation] {
		components.flatMap { $0 }
	}

	static func buildArray(_ components: [[Operation]]) -> [Operation] {
		components.flatMap { $0 }
	}

	static func buildOptional(_ component: [Operation]?) -> [Operation] {
		component ?? []
	}
}

// MARK: - Nested data structs
extension OnboardingScenarioBuilder {

	enum Operation {

		case wait(Wait)
		case change(Change)

		var duration: Duration {
			switch self {
			case let .wait(wait): wait.duration
			case let .change(change): change.duration
			}
		}
	}
}

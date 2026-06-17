@testable import Analytics

actor AnalyticsEngineMock: AnalyticsEngine {

	private(set) var invocations: [Action] = []
	var stubs = Stubs()

	init(failureCount: Int = 0) {
		stubs.failureCount = failureCount
	}
}

// MARK: - AnalyticsEngine
extension AnalyticsEngineMock {

	func send(_ events: [AnalyticsPayload]) async throws {
		invocations.append(.send(events: events))
		guard stubs.failureCount == 0 else {
			stubs.failureCount -= 1
			throw TestError.expected
		}
	}
}

// MARK: - Nested Data Structs
extension AnalyticsEngineMock {

	enum Action {
		case send(events: [AnalyticsPayload])
	}

	struct Stubs {
		var failureCount = 0
	}
}

enum TestError: Error {
	case expected
}

//
//  ContentAnalyticsServiceMock.swift
//  iOSTests
//
//  Created by Anton Cherkasov on 11.07.2026.
//

import CorePresentation
@testable import iOS

actor ContentAnalyticsServiceMock {

	private(set) var invocations: [Action] = []

	private var continuation: CheckedContinuation<Action?, Never>?
}

// MARK: - ContentAnalyticsServiceProtocol
extension ContentAnalyticsServiceMock: ContentAnalyticsServiceProtocol {

	func track(_ event: ContentAnalyticsEvent) async {
		append(.track(event))
	}

	func flush() async {
		append(.flush)
	}
}

// MARK: - Public Interface
extension ContentAnalyticsServiceMock {

	func waitForInvocation() async -> Action? {
		if let invocation = invocations.first {
			return invocation
		}
		return await withCheckedContinuation { continuation in
			self.continuation = continuation
		}
	}
}

// MARK: - Private methods
private extension ContentAnalyticsServiceMock {

	func append(_ action: Action) {
		invocations.append(action)
		continuation?.resume(returning: action)
		continuation = nil
	}
}

// MARK: - Nested data structs
extension ContentAnalyticsServiceMock {

	enum Action {
		case track(ContentAnalyticsEvent)
		case flush
	}
}

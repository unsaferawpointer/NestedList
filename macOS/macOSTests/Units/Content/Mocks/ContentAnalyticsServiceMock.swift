//
//  ContentAnalyticsServiceMock.swift
//  macOSTests
//
//  Created by Anton Cherkasov on 30.06.2026.
//

@testable import Nested_List

actor ContentAnalyticsServiceMock {

	private(set) var invocations: [Action] = []
}

// MARK: - ContentAnalyticsServiceProtocol
extension ContentAnalyticsServiceMock: ContentAnalyticsServiceProtocol {

	func track(_ event: ContentAnalyticsEvent) async {
		invocations.append(.track(event))
	}

	func flush() async {
		invocations.append(.flush)
	}
}

// MARK: - Nested data structs
extension ContentAnalyticsServiceMock {

	enum Action {
		case track(ContentAnalyticsEvent)
		case flush
	}
}

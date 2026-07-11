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

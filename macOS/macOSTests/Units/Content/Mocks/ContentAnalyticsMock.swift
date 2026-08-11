//
//  ContentAnalyticsMock.swift
//  macOSTests
//
//  Created by Anton Cherkasov on 30.06.2026.
//

import CorePresentation
@testable import Nested_List

actor ContentAnalyticsMock {

	private(set) var invocations: [Action] = []
}

// MARK: - ConcreteAnalyticsServiceProtocol<ContentAnalyticsEvent>
extension ContentAnalyticsMock: ConcreteAnalyticsServiceProtocol<ContentAnalyticsEvent> {

	func track(_ event: ContentAnalyticsEvent) async {
		invocations.append(.track(event))
	}

	func flush() async {
		invocations.append(.flush)
	}
}

// MARK: - Nested data structs
extension ContentAnalyticsMock {

	enum Action {
		case track(ContentAnalyticsEvent)
		case flush
	}
}

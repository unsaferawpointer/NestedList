//
//  ContentAnalyticsService.swift
//  Nested List
//
//  Created by Anton Cherkasov on 30.06.2026.
//

import Analytics
import CorePresentation

protocol ContentAnalyticsServiceProtocol {
	func track(_ event: ContentAnalyticsEvent) async
	func flush() async
}

final class ContentAnalyticsService {

	// MARK: - DI

	private let analytics: any AnalyticsServiceProtocol

	init(analytics: any AnalyticsServiceProtocol = AnalyticsService(engine: AmplitudeService())) {
		self.analytics = analytics
	}
}

// MARK: - ContentAnalyticsServiceProtocol
extension ContentAnalyticsService: ContentAnalyticsServiceProtocol {

	func track(_ event: ContentAnalyticsEvent) async {
		await analytics.track(event)
	}

	func flush() async {
		await analytics.flush()
	}
}

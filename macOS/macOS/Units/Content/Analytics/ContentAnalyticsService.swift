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

	init(analytics: any AnalyticsServiceProtocol) {
		self.analytics = analytics
	}

	convenience init(identityProvider: AnalyticsIdentityProvider = AnalyticsIdentityProvider()) {
		self.init(
			analytics: AnalyticsService(
				engine: AmplitudeService(),
				userIdentifier: identityProvider.userIdentifier
			)
		)
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

//
//  ContentAnalyticsService.swift
//  CorePresentation
//
//  Created by Anton Cherkasov on 11.07.2026.
//

import Analytics

public protocol ContentAnalyticsServiceProtocol {
	func track(_ event: ContentAnalyticsEvent) async
	func flush() async
}

public final class ContentAnalyticsService {

	// MARK: - DI

	private let analytics: any AnalyticsServiceProtocol

	// MARK: - Initialization

	public init(analytics: any AnalyticsServiceProtocol) {
		self.analytics = analytics
	}

	public convenience init(identityProvider: AnalyticsIdentityProvider = AnalyticsIdentityProvider()) {
		self.init(analytics: ApplicationAnalyticsService.shared)
	}
}

// MARK: - ContentAnalyticsServiceProtocol
extension ContentAnalyticsService: ContentAnalyticsServiceProtocol {

	public func track(_ event: ContentAnalyticsEvent) async {
		await analytics.track(event)
	}

	public func flush() async {
		await analytics.flush()
	}
}

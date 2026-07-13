//
//  OnboardingAnalyticsService.swift
//  CorePresentation
//
//  Created by Codex on 13.07.2026.
//

import Analytics

public protocol OnboardingAnalyticsServiceProtocol: Sendable {
	func track(_ event: OnboardingAnalyticsEvent) async
}

public final class OnboardingAnalyticsService {

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

// MARK: - OnboardingAnalyticsServiceProtocol
extension OnboardingAnalyticsService: OnboardingAnalyticsServiceProtocol {

	public func track(_ event: OnboardingAnalyticsEvent) async {
		await analytics.track(event)
		await analytics.flush()
	}
}

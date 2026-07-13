//
//  SettingsAnalyticsService.swift
//  CorePresentation
//
//  Created by Codex on 13.07.2026.
//

import Analytics

public protocol SettingsAnalyticsServiceProtocol: Sendable {
	func track(_ event: SettingsAnalyticsEvent) async
}

public final class SettingsAnalyticsService {

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

// MARK: - SettingsAnalyticsServiceProtocol
extension SettingsAnalyticsService: SettingsAnalyticsServiceProtocol {

	public func track(_ event: SettingsAnalyticsEvent) async {
		await analytics.track(event)
		await analytics.flush()
	}
}

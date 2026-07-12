//
//  PickerAnalyticsService.swift
//  CorePresentation
//
//  Created by Anton Cherkasov on 11.07.2026.
//

import Analytics

public protocol PickerAnalyticsServiceProtocol: Sendable {
	func track(_ event: PickerAnalyticsEvent) async
}

public final class PickerAnalyticsService {

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

// MARK: - PickerAnalyticsServiceProtocol
extension PickerAnalyticsService: PickerAnalyticsServiceProtocol {

	public func track(_ event: PickerAnalyticsEvent) async {
		await analytics.track(event)
		await analytics.flush()
	}
}

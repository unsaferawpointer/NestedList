//
//  ItemDetailsAnalyticsService.swift
//  CorePresentation
//
//  Created by Anton Cherkasov on 12.07.2026.
//

import Analytics

public protocol ItemDetailsAnalyticsServiceProtocol: Sendable {
	func track(_ event: ItemDetailsAnalyticsEvent) async
}

public final class ItemDetailsAnalyticsService {

	// MARK: - DI

	private let analytics: any AnalyticsServiceProtocol

	// MARK: - Initialization

	public init(analytics: any AnalyticsServiceProtocol) {
		self.analytics = analytics
	}

	public convenience init(identityProvider: AnalyticsIdentityProvider = AnalyticsIdentityProvider()) {
		self.init(
			analytics: AnalyticsService(
				engine: AmplitudeService(),
				identityProvider: identityProvider,
				metadataProvider: SystemAnalyticsPayloadMetadataProvider()
			)
		)
	}
}

// MARK: - ItemDetailsAnalyticsServiceProtocol
extension ItemDetailsAnalyticsService: ItemDetailsAnalyticsServiceProtocol {

	public func track(_ event: ItemDetailsAnalyticsEvent) async {
		await analytics.track(event)
		await analytics.flush()
	}
}

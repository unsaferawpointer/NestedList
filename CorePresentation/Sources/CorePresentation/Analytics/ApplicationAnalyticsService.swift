//
//  ApplicationAnalyticsService.swift
//  CorePresentation
//

import Analytics

/// Shared analytics service for production event tracking.
public enum ApplicationAnalyticsService {

	public static let shared: any AnalyticsServiceProtocol = AnalyticsService(
		engine: AmplitudeService(),
		identityProvider: AnalyticsIdentityProvider(),
		metadataProvider: SystemAnalyticsPayloadMetadataProvider()
	)
}

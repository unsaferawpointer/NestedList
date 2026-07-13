//
//  TargetDestinationAnalyticsService.swift
//  iOS
//
//  Created by Codex on 13.07.2026.
//

import Analytics
import CorePresentation

protocol TargetDestinationAnalyticsServiceProtocol: Sendable {
	func track(_ event: TargetDestinationAnalyticsEvent) async
}

final class TargetDestinationAnalyticsService {

	// MARK: - DI

	private let analytics: any AnalyticsServiceProtocol

	// MARK: - Initialization

	init(analytics: any AnalyticsServiceProtocol) {
		self.analytics = analytics
	}

	convenience init() {
		self.init(analytics: ApplicationAnalyticsService.shared)
	}
}

// MARK: - TargetDestinationAnalyticsServiceProtocol
extension TargetDestinationAnalyticsService: TargetDestinationAnalyticsServiceProtocol {

	func track(_ event: TargetDestinationAnalyticsEvent) async {
		await analytics.track(event)
		await analytics.flush()
	}
}

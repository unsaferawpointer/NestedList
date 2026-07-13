//
//  ReorderAnalyticsService.swift
//  iOS
//
//  Created by Codex on 13.07.2026.
//

import Analytics
import CorePresentation

protocol ReorderAnalyticsServiceProtocol: Sendable {
	func track(_ event: ReorderAnalyticsEvent) async
}

final class ReorderAnalyticsService {

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

// MARK: - ReorderAnalyticsServiceProtocol
extension ReorderAnalyticsService: ReorderAnalyticsServiceProtocol {

	func track(_ event: ReorderAnalyticsEvent) async {
		await analytics.track(event)
		await analytics.flush()
	}
}

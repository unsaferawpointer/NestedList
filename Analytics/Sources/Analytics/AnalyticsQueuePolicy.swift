//
//  AnalyticsQueuePolicy.swift
//  Analytics
//

import Foundation

/// Policy that controls in-memory analytics queue behavior.
public struct AnalyticsQueuePolicy: Sendable, Equatable {

	/// Maximum number of events kept in memory. Older events are discarded first.
	public let cacheLimit: Int

	/// Number of events that triggers automatic delivery from `AnalyticsService.track(_:)`.
	public let batchSize: Int

	public init(cacheLimit: Int = 100, batchSize: Int = 10) {
		self.cacheLimit = max(1, cacheLimit)
		self.batchSize = max(1, batchSize)
	}
}

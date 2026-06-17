//
//  AnalyticsEngine.swift
//  Analytics
//

import Foundation

/// A transport layer that delivers analytics events to an external analytics backend.
///
/// `AnalyticsService` owns queueing, batching, retry, and cache-limit behavior. Concrete
/// engine implementations should focus only on converting the provided payloads into the
/// backend request format and sending that request.
public protocol AnalyticsEngine: Sendable {

	/// Sends a batch of analytics events.
	///
	/// Throw an error when the batch was not accepted or could not be delivered. The service
	/// will keep the failed batch in memory and retry it on a later `flush()` call.
	///
	/// - Parameter events: Ordered analytics payloads ready for delivery.
	func send(_ events: [AnalyticsPayload]) async throws
}

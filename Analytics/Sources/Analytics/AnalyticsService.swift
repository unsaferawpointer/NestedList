//
//  AnalyticsService.swift
//  Analytics
//

import Foundation

/// Public interface for tracking analytics events.
///
/// Implementations are responsible for accepting typed events and deciding when accumulated
/// events should be delivered to an analytics backend.
public protocol AnalyticsServiceProtocol: Sendable {

	/// Adds an event to the analytics queue.
	///
	/// The event may be sent immediately when the queue reaches the configured batch size.
	/// Otherwise it remains cached in memory until more events arrive or `flush()` is called.
	func track<E: AnalyticsEvent>(_ event: E) async

	/// Attempts to send all currently cached events.
	///
	/// Use this before important lifecycle transitions, such as app termination or backgrounding.
	func flush() async
}

/// Actor-based analytics service that batches events and sends them through an `AnalyticsEngine`.
///
/// The service keeps an in-memory queue, trims it to the configured cache limit, sends events in
/// ordered batches, and preserves failed batches for a later retry. Actor isolation protects queue
/// state when events are tracked concurrently.
public actor AnalyticsService {

	// MARK: - DI

	private let engine: any AnalyticsEngine

	// MARK: - Constants

	private let userIdentifier: UUID
	private let sessionIdentifier: UUID
	private let queuePolicy: AnalyticsQueuePolicy

	// MARK: - Internal state

	private var cache: [AnalyticsPayload] = []
	private var isFlushing = false

	/// Creates an analytics service.
	///
	/// - Parameters:
	///   - engine: Transport layer used to deliver event batches.
	///   - userIdentifier: Identifier of the user associated with tracked events.
	///   - sessionIdentifier: Identifier of the current application session.
	///   - queuePolicy: Policy that controls in-memory caching and batch delivery.
	public init(
		engine: any AnalyticsEngine,
		userIdentifier: UUID = UUID(),
		sessionIdentifier: UUID = UUID(),
		queuePolicy: AnalyticsQueuePolicy = AnalyticsQueuePolicy()
	) {
		self.engine = engine
		self.userIdentifier = userIdentifier
		self.sessionIdentifier = sessionIdentifier
		self.queuePolicy = queuePolicy
	}
}

// MARK: - AnalyticsServiceProtocol
extension AnalyticsService: AnalyticsServiceProtocol {

	public func track<E: AnalyticsEvent>(_ event: E) async {
		let payload = AnalyticsPayload(
			event: event,
			userIdentifier: userIdentifier,
			sessionIdentifier: sessionIdentifier
		)
		cache.append(payload)
		trimCacheIfNeeded()

		guard cache.count >= queuePolicy.batchSize else {
			return
		}
		await flush()
	}

	public func flush() async {
		guard !isFlushing else {
			return
		}
		isFlushing = true
		defer {
			isFlushing = false
		}

		while !cache.isEmpty {
			let batch = Array(cache.prefix(queuePolicy.batchSize))
			do {
				try await engine.send(batch)
				cache.removeFirst(batch.count)
			} catch {
				return
			}
		}
	}
}

// MARK: - Private methods
private extension AnalyticsService {

	func trimCacheIfNeeded() {
		guard cache.count > queuePolicy.cacheLimit else {
			return
		}
		cache.removeFirst(cache.count - queuePolicy.cacheLimit)
	}
}

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
	private let identityProvider: any AnalyticsIdentityProviding
	private let metadataProvider: any AnalyticsPayloadMetadataProvider

	// MARK: - Constants

	private let queuePolicy: AnalyticsQueuePolicy

	// MARK: - Internal state

	private var cache: [AnalyticsPayload] = []
	private var isFlushing = false

		/// Creates an analytics service.
	///
	/// - Parameters:
	///   - engine: Transport layer used to deliver event batches.
	///   - identityProvider: Provider used to attach user and session identifiers to tracked events.
	///   - metadataProvider: Provider used to attach environment metadata to tracked events.
	///   - queuePolicy: Policy that controls in-memory caching and batch delivery.
	public init(
		engine: any AnalyticsEngine,
		identityProvider: any AnalyticsIdentityProviding,
		metadataProvider: any AnalyticsPayloadMetadataProvider,
		queuePolicy: AnalyticsQueuePolicy = AnalyticsQueuePolicy()
	) {
		self.engine = engine
		self.identityProvider = identityProvider
		self.metadataProvider = metadataProvider
		self.queuePolicy = queuePolicy
	}
}

// MARK: - AnalyticsServiceProtocol
extension AnalyticsService: AnalyticsServiceProtocol {

	public func track<E: AnalyticsEvent>(_ event: E) async {
		let payload = AnalyticsPayload(
			event: event,
			userIdentifier: identityProvider.userIdentifier,
			sessionIdentifier: identityProvider.sessionIdentifier,
			metadata: metadataProvider.metadata()
		)
		cache.append(payload)
		logTrackedEvent(payload)
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

	func logTrackedEvent(_ payload: AnalyticsPayload) {
		#if DEBUG
		let parameters = formattedParameters(payload.parameters)

		print(
			"[Analytics]\n"
			+ "Event: \(payload.area).\(payload.name)\n"
			+ "User: \(payload.userIdentifier)\n"
			+ "Session: \(payload.sessionIdentifier)\n"
			+ "Parameters:\n\(parameters)"
		)
		#endif
	}

	func formattedParameters(_ parameters: [String: AnalyticsValue]) -> String {
		guard !parameters.isEmpty else {
			return "\t- empty"
		}

		return parameters
			.sorted { $0.key < $1.key }
			.map { "\t- \($0.key): \(formattedValue($0.value))" }
			.joined(separator: "\n")
	}

	func formattedValue(_ value: AnalyticsValue) -> String {
		switch value {
		case let .string(value):
			return value.debugDescription
		case let .int(value):
			return String(value)
		case let .double(value):
			return String(value)
		case let .bool(value):
			return String(value)
		}
	}
}

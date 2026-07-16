//
//  ConcreteAnalyticsService.swift
//  CorePresentation
//

import Analytics

/// Typed interface for tracking one concrete analytics event type.
///
/// Use this protocol at feature boundaries when a view model or presenter should only emit
/// events from its own analytics namespace. The generic event type keeps call sites strongly
/// typed while still allowing production code to forward events into the shared analytics
/// pipeline and tests to provide lightweight mocks.
public protocol ConcreteAnalyticsServiceProtocol<T>: Sendable {

	/// Event type accepted by this service.
	associatedtype T: AnalyticsEvent

	/// Queues an analytics event for delivery.
	///
	/// Implementations may batch events and are not required to send them immediately.
	func track(_ event: T) async

	/// Sends any queued analytics events when immediate delivery is required.
	///
	/// Prefer calling this from lifecycle boundaries, such as app termination or document close,
	/// instead of after every tracked event.
	func flush() async
}

/// Production-ready typed analytics service for one event namespace.
///
/// The service adapts feature-specific analytics dependencies to the shared application analytics
/// pipeline. It keeps the feature surface narrow by accepting only `T`, while delegating batching,
/// metadata enrichment, identity handling, and transport to the injected `AnalyticsServiceProtocol`.
public final class ConcreteAnalyticsService<T: AnalyticsEvent>: Sendable {

	// MARK: - DI

	private let analytics: any AnalyticsServiceProtocol

	// MARK: - Initialization

	/// Creates a typed analytics service backed by the provided shared analytics implementation.
	///
	/// - Parameter analytics: Service that receives typed events and handles batching and delivery.
	public init(analytics: any AnalyticsServiceProtocol) {
		self.analytics = analytics
	}

	/// Creates a production analytics service backed by `ApplicationAnalyticsService.shared`.
	///
	/// - Parameter identityProvider: Reserved for call-site compatibility with older unit-specific services.
	public convenience init(identityProvider: AnalyticsIdentityProvider = AnalyticsIdentityProvider()) {
		self.init(analytics: ApplicationAnalyticsService.shared)
	}
}

// MARK: - ConcreteAnalyticsServiceProtocol
extension ConcreteAnalyticsService: ConcreteAnalyticsServiceProtocol {

	public func track(_ event: T) async {
		await analytics.track(event)
	}

	public func flush() async {
		await analytics.flush()
	}
}

// MARK: - Default Implementation
public extension ConcreteAnalyticsServiceProtocol {

	func flush() async { }
}

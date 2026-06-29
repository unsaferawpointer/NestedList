//
//  AnalyticsPayload.swift
//  Analytics
//

import Foundation

/// A queued analytics event prepared for delivery by `AnalyticsService`.
///
/// Payloads add service-level metadata, such as user and session identifiers, to typed
/// `AnalyticsEvent` values while preserving the original event object for transport-specific
/// encoding by an `AnalyticsEngine`.
public struct AnalyticsPayload: Sendable, Identifiable {

	/// Unique identifier of the queued payload.
	public let id: UUID

	/// Original typed analytics event.
	public let event: any AnalyticsEvent

	/// Identifier of the user associated with the event.
	public let userIdentifier: UUID

	/// Identifier of the application session associated with the event.
	public let sessionIdentifier: UUID

	/// Date when the payload was created and placed into the service queue.
	public let createdAt: Date

	public init(
		id: UUID = UUID(),
		event: any AnalyticsEvent,
		userIdentifier: UUID,
		sessionIdentifier: UUID,
		createdAt: Date = Date()
	) {
		self.id = id
		self.event = event
		self.userIdentifier = userIdentifier
		self.sessionIdentifier = sessionIdentifier
		self.createdAt = createdAt
	}
}

extension AnalyticsPayload {

	/// Stable event space forwarded from the wrapped event.
	public var space: String {
		return event.space
	}

	/// Stable event name forwarded from the wrapped event.
	public var name: String {
		return event.name
	}

	/// Event parameters forwarded from the wrapped event.
	public var parameters: [String: AnalyticsValue] {
		return event.parameters
	}
}

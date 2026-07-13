//
//  AmplitudeEvent.swift
//  CorePresentation
//

import Analytics

/// Amplitude HTTP API V2 event encoded from a generic `AnalyticsPayload`.
struct AmplitudeEvent {

	/// Stable user identifier sent as Amplitude `user_id`.
	let userID: String

	/// Event name sent as Amplitude `event_type`.
	let eventType: String

	/// Event creation time in milliseconds since the Unix epoch.
	let time: Int64

	/// Session start time in milliseconds since the Unix epoch.
	let sessionID: Int64

	/// Unique payload identifier used by Amplitude for event deduplication.
	let insertID: String

	/// User region code attached to the event when available.
	let region: String?

	/// User country code attached to the event when available.
	let country: String?

	/// Preferred language code attached to the event when available.
	let language: String?

	/// Platform where the event was produced.
	let platform: String

	/// Operating system name where the event was produced.
	let osName: String

	/// Operating system version where the event was produced.
	let osVersion: String

	/// Application version where the event was produced.
	let appVersion: String?

	private let eventProperties: [String: AmplitudeValue]

	// MARK: - Initialization

	/// Creates an Amplitude event from a transport-agnostic analytics payload.
	///
	/// - Parameter payload: Analytics payload containing event data, identifiers, and environment metadata.
	init(payload: AnalyticsPayload) {

		var eventProperties = payload.parameters.mapValues(AmplitudeValue.init)
		eventProperties["area"] = .string(payload.area)

		self.userID = payload.userIdentifier.uuidString
		self.eventType = payload.name.rawValue
		self.time = Int64((payload.createdAt.timeIntervalSince1970 * 1000).rounded())
		self.sessionID = Int64((payload.sessionStartedAt.timeIntervalSince1970 * 1000).rounded())
		self.insertID = payload.id.uuidString
		self.region = payload.metadata.region
		self.country = payload.metadata.country
		self.language = payload.metadata.language
		self.platform = payload.metadata.platform
		self.osName = payload.metadata.osName
		self.osVersion = payload.metadata.osVersion
		self.appVersion = payload.metadata.appVersion
		self.eventProperties = eventProperties
	}
}

// MARK: - Encodable
extension AmplitudeEvent: Encodable {

	enum CodingKeys: String, CodingKey {
		case userID = "user_id"
		case eventType = "event_type"
		case time
		case sessionID = "session_id"
		case insertID = "insert_id"
		case region
		case country
		case language
		case platform
		case osName = "os_name"
		case osVersion = "os_version"
		case appVersion = "app_version"
		case eventProperties = "event_properties"
	}
}

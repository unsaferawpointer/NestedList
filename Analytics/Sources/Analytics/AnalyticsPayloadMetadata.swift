//
//  AnalyticsPayloadMetadata.swift
//  Analytics
//

import Foundation

/// Environment metadata attached to each analytics payload before transport delivery.
public struct AnalyticsPayloadMetadata: Sendable, Equatable {

	/// User region code when available.
	public let region: String?

	/// User country code when available.
	public let country: String?

	/// Preferred language code when available.
	public let language: String?

	/// Platform where the event was produced.
	public let platform: String

	/// Operating system name where the event was produced.
	public let osName: String

	/// Operating system version where the event was produced.
	public let osVersion: String

	/// Application version where the event was produced.
	public let appVersion: String?

	public init(
		region: String?,
		country: String?,
		language: String?,
		platform: String,
		osName: String,
		osVersion: String,
		appVersion: String?
	) {
		self.region = region
		self.country = country
		self.language = language
		self.platform = platform
		self.osName = osName
		self.osVersion = osVersion
		self.appVersion = appVersion
	}
}

// MARK: - Empty value
public extension AnalyticsPayloadMetadata {

	/// Empty metadata value used when environment details are unavailable.
	static var empty: AnalyticsPayloadMetadata {
		return AnalyticsPayloadMetadata(
			region: nil,
			country: nil,
			language: nil,
			platform: "",
			osName: "",
			osVersion: "",
			appVersion: nil
		)
	}
}

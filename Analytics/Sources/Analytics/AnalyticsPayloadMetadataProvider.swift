//
//  AnalyticsPayloadMetadataProvider.swift
//  Analytics
//

/// Provides environment metadata that should be attached to tracked analytics payloads.
public protocol AnalyticsPayloadMetadataProvider: Sendable {

	/// Returns current environment metadata for a payload being created.
	func metadata() -> AnalyticsPayloadMetadata
}

//
//  SystemAnalyticsPayloadMetadataProvider.swift
//  CorePresentation
//

import Analytics
import Foundation

/// Default metadata provider backed by Foundation process, bundle, and locale APIs.
public struct SystemAnalyticsPayloadMetadataProvider {

	public init() { }
}

// MARK: - AnalyticsPayloadMetadataProvider
extension SystemAnalyticsPayloadMetadataProvider: AnalyticsPayloadMetadataProvider {

	public func metadata() -> AnalyticsPayloadMetadata {
		return AnalyticsPayloadMetadata(
			region: Locale.autoupdatingCurrent.region?.identifier,
			country: Locale.autoupdatingCurrent.region?.identifier,
			language: Locale.autoupdatingCurrent.language.languageCode?.identifier,
			platform: platform,
			osName: osName,
			osVersion: ProcessInfo.processInfo.operatingSystemVersionString,
			appVersion: Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
		)
	}
}

// MARK: - Private properties
private extension SystemAnalyticsPayloadMetadataProvider {

	var platform: String {
		#if os(macOS)
		return "macOS"
		#elseif os(iOS)
		return "iOS"
		#else
		return "Apple"
		#endif
	}

	var osName: String {
		#if os(macOS)
		return "macOS"
		#elseif os(iOS)
		return "iOS"
		#else
		return "Apple OS"
		#endif
	}
}

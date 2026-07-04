//
//  AmplitudeAPIKeyProviding.swift
//  CorePresentation
//

import Foundation

/// Provides Amplitude API key.
protocol AmplitudeAPIKeyProviding: Sendable {

	/// Amplitude project API key.
	var apiKey: String? { get }
}

/// Default Amplitude API key provider.
struct AmplitudeAPIKeyProvider: Sendable {

	// MARK: - Constants

	private static let infoPlistKey = "NestedListAnalyticsAPIKey"

	// MARK: - Properties

	private let infoDictionary: [String: String]?

	// MARK: - Initialization

	init(infoDictionary: [String: String]? = nil) {
		self.infoDictionary = infoDictionary
	}
}

// MARK: - AmplitudeAPIKeyProviding
extension AmplitudeAPIKeyProvider: AmplitudeAPIKeyProviding {

	var apiKey: String? {
		if let infoDictionary {
			return infoDictionary[Self.infoPlistKey]
		}
		return Bundle.main.object(forInfoDictionaryKey: Self.infoPlistKey) as? String
	}
}

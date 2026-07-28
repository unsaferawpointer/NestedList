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
struct AmplitudeAPIKeyProvider: Sendable { }

// MARK: - AmplitudeAPIKeyProviding
extension AmplitudeAPIKeyProvider: AmplitudeAPIKeyProviding {

	var apiKey: String? {
		#if DEBUG
		return nil
		#else
		return Self.releaseAPIKey
		#endif
	}
}

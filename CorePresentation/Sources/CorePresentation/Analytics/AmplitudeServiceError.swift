//
//  AmplitudeServiceError.swift
//  CorePresentation
//

/// Errors produced by `AmplitudeService` while preparing or delivering an analytics batch.
enum AmplitudeServiceError: Error, Equatable {

	/// The service cannot build an Amplitude request because the API key is missing or empty.
	case missingAPIKey

	/// The transport completed, but the response was not an HTTP response.
	case invalidResponse

	/// Amplitude returned an HTTP response outside the successful status-code range.
	///
	/// - Parameters:
	///   - statusCode: HTTP status code returned by Amplitude.
	///   - response: Raw response body decoded as UTF-8 when available.
	case rejected(statusCode: Int, response: String?)
}

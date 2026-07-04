//
//  AmplitudeRequest.swift
//  CorePresentation
//

/// Request body sent to Amplitude HTTP API V2.
struct AmplitudeRequest {

	/// Amplitude project API key used to authenticate the batch.
	let apiKey: String

	/// Analytics events included in a single delivery batch.
	let events: [AmplitudeEvent]
}

// MARK: - Encodable
extension AmplitudeRequest: Encodable {

	enum CodingKeys: String, CodingKey {
		case apiKey = "api_key"
		case events
	}
}

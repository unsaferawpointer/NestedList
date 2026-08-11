//
//  AmplitudeService.swift
//  CorePresentation
//
//  Created by Anton Cherkasov on 30.06.2026.
//

import Analytics
import Foundation
import OSLog

public final class AmplitudeService: Sendable {

	// MARK: - DI

	private let session: any AmplitudeSession

	// MARK: - Constants

	private let isSendingEnabled: Bool
	private let apiKey: String?
	private let endpoint: URL
	private let logger = Logger(subsystem: "NestedList", category: "Amplitude")

	// MARK: - Initialization

	public convenience init(
		isSendingEnabled: Bool = true
	) {
		self.init(
			apiKeyProvider: AmplitudeAPIKeyProvider(),
			endpoint: AmplitudeAPI.endpoint,
			session: URLSession.shared,
			isSendingEnabled: isSendingEnabled
		)
	}

	public convenience init(
		apiKey: String?,
		isSendingEnabled: Bool = true
	) {
		self.init(
			apiKey: apiKey,
			endpoint: AmplitudeAPI.endpoint,
			session: URLSession.shared,
			isSendingEnabled: isSendingEnabled
		)
	}

	public convenience init(
		apiKey: String?,
		endpoint: URL,
		isSendingEnabled: Bool = true
	) {
		self.init(apiKey: apiKey, endpoint: endpoint, session: URLSession.shared, isSendingEnabled: isSendingEnabled)
	}

	convenience init(
		apiKeyProvider: any AmplitudeAPIKeyProviding,
		endpoint: URL,
		session: any AmplitudeSession,
		isSendingEnabled: Bool = true
	) {
		self.init(
			apiKey: apiKeyProvider.apiKey,
			endpoint: endpoint,
			session: session,
			isSendingEnabled: isSendingEnabled
		)
	}

	init(apiKey: String?, endpoint: URL, session: any AmplitudeSession, isSendingEnabled: Bool = true) {
		self.apiKey = apiKey
		self.endpoint = endpoint
		self.session = session
		self.isSendingEnabled = isSendingEnabled
	}
}

// MARK: - AnalyticsEngine
extension AmplitudeService: AnalyticsEngine {

	public func send(_ events: [AnalyticsPayload]) async throws {
		guard !events.isEmpty else {
			return
		}

		guard isSendingEnabled else {
			logger.info("Skipped analytics events batch because sending is disabled. count=\(events.count)")
			return
		}

		do {
			let request = try makeRequest(events: events)
			let (data, response) = try await session.data(for: request)

			guard let httpResponse = response as? HTTPURLResponse else {
				throw AmplitudeServiceError.invalidResponse
			}

			guard (200..<300).contains(httpResponse.statusCode) else {
				throw AmplitudeServiceError.rejected(
					statusCode: httpResponse.statusCode,
					response: String(data: data, encoding: .utf8)
				)
			}

			logger.info("Sent analytics events batch. count=\(events.count)")
		} catch {
			log(error: error, eventsCount: events.count)
			throw error
		}
	}
}

// MARK: - Private methods
private extension AmplitudeService {

	func makeRequest(events: [AnalyticsPayload]) throws -> URLRequest {
		guard let apiKey = apiKey?.trimmingCharacters(in: .whitespacesAndNewlines), !apiKey.isEmpty else {
			throw AmplitudeServiceError.missingAPIKey
		}

		let body = AmplitudeRequest(
			apiKey: apiKey,
			events: events.map { AmplitudeEvent(payload: $0) }
		)
		var request = URLRequest(url: endpoint)
		request.httpMethod = "POST"
		request.setValue("application/json", forHTTPHeaderField: "Content-Type")
		request.httpBody = try JSONEncoder().encode(body)
		return request
	}

	func log(error: Error, eventsCount: Int) {
		switch error {
		case AmplitudeServiceError.missingAPIKey:
			logger.error("Failed to send analytics events. reason=missing_api_key count=\(eventsCount)")
		case AmplitudeServiceError.invalidResponse:
			logger.error("Failed to send analytics events. reason=invalid_response count=\(eventsCount)")
		case let AmplitudeServiceError.rejected(statusCode, response):
			logger.error("Failed to send analytics events. reason=rejected statusCode=\(statusCode) count=\(eventsCount) response=\(response ?? "", privacy: .public)")
		default:
			logger.error("Failed to send analytics events. reason=transport_error count=\(eventsCount) error=\(String(describing: error), privacy: .public)")
		}
	}
}

// MARK: - AmplitudeSession
protocol AmplitudeSession: Sendable {
	func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

// MARK: - AmplitudeSession
extension URLSession: AmplitudeSession { }

//
//  AmplitudeService.swift
//  CorePresentation
//
//  Created by Anton Cherkasov on 30.06.2026.
//

import Analytics
import OSLog

public final class AmplitudeService {

	private let logger = Logger(subsystem: "NestedList", category: "Amplitude")

	public init() { }
}

// MARK: - AnalyticsEngine
extension AmplitudeService: AnalyticsEngine {

	public func send(_ events: [AnalyticsPayload]) async throws {
		logger.info("Sending analytics events batch. count=\(events.count)")

		for event in events {
			let parameters = String(describing: event.parameters)
			logger.info("Sending analytics event. area=\(event.area, privacy: .public) name=\(event.name, privacy: .public) payloadID=\(event.id.uuidString, privacy: .public) userID=\(event.userIdentifier.uuidString, privacy: .public) sessionID=\(event.sessionIdentifier.uuidString, privacy: .public) parameters=\(parameters, privacy: .public)")
		}
	}
}

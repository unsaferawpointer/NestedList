import Analytics
import Foundation
import Testing
@testable import CorePresentation

struct AmplitudeServiceTests { }

// MARK: - AmplitudeAPIKeyProvider
extension AmplitudeServiceTests {

	@Test func apiKeyProvider_returnsAPIKeyFromInfoDictionary() {
		let sut = AmplitudeAPIKeyProvider(infoDictionary: ["NestedListAnalyticsAPIKey": "test-api-key"])

		#expect(sut.apiKey == "test-api-key")
	}

	@Test func apiKeyProvider_whenInfoDictionaryDoesNotContainKey_returnsNil() {
		let sut = AmplitudeAPIKeyProvider(infoDictionary: [:])

		#expect(sut.apiKey == nil)
	}
}

// MARK: - AnalyticsEngine
extension AmplitudeServiceTests {

	@Test func send_whenSendingIsDisabled_doesNotSendRequest() async throws {
		let endpoint = try #require(URL(string: "https://example.com/amplitude"))
		let session = AmplitudeSessionMock(
			response: try #require(HTTPURLResponse(url: endpoint, statusCode: 200, httpVersion: nil, headerFields: nil))
		)
		let sut = AmplitudeService(
			apiKey: "test-api-key",
			endpoint: endpoint,
			session: session,
			isSendingEnabled: false
		)
		let payload = makePayload()

		try await sut.send([payload])

		#expect(await session.requests.isEmpty)
	}

	@Test func send_encodesAmplitudeHTTPRequest() async throws {
		let endpoint = try #require(URL(string: "https://example.com/amplitude"))
		let session = AmplitudeSessionMock(
			response: try #require(HTTPURLResponse(url: endpoint, statusCode: 200, httpVersion: nil, headerFields: nil))
		)
		let sut = AmplitudeService(apiKey: "test-api-key", endpoint: endpoint, session: session)
		let userIdentifier = try #require(UUID(uuidString: "11111111-1111-1111-1111-111111111111"))
		let sessionIdentifier = try #require(UUID(uuidString: "22222222-2222-2222-2222-222222222222"))
		let sessionStartedAt = Date(timeIntervalSince1970: 10.5)
		let payloadIdentifier = try #require(UUID(uuidString: "33333333-3333-3333-3333-333333333333"))
		let payload = AnalyticsPayload(
			id: payloadIdentifier,
			event: TestEvent(area: "content", name: "button_click", parameters: [
				"id": .string("new-item"),
				"source": .string("toolbar"),
				"enabled": .bool(true),
				"count": .int(3),
				"ratio": .double(1.5)
			]),
			userIdentifier: userIdentifier,
			sessionIdentifier: sessionIdentifier,
			sessionStartedAt: sessionStartedAt,
			createdAt: Date(timeIntervalSince1970: 1.234),
			metadata: AnalyticsPayloadMetadata(
				region: "CA",
				country: "US",
				language: "en",
				platform: "macOS",
				osName: "macOS",
				osVersion: "Version 15.0",
				appVersion: "2.3.0"
			)
		)

		try await sut.send([payload])

		let requests = await session.requests
		let request = try #require(requests.first)
		let bodyData = try #require(request.httpBody)
		let body = try #require(JSONSerialization.jsonObject(with: bodyData) as? [String: Any])
		let events = try #require(body["events"] as? [[String: Any]])
		let event = try #require(events.first)
		let eventProperties = try #require(event["event_properties"] as? [String: Any])

		#expect(request.url == endpoint)
		#expect(request.httpMethod == "POST")
		#expect(request.value(forHTTPHeaderField: "Content-Type") == "application/json")
		#expect(body["api_key"] as? String == "test-api-key")
		#expect(event["user_id"] as? String == userIdentifier.uuidString)
		#expect(event["event_type"] as? String == "button_click")
		#expect(event["time"] as? Int == 1234)
		#expect(event["session_id"] as? Int == 10500)
		#expect(event["insert_id"] as? String == payloadIdentifier.uuidString)
		#expect(event["region"] as? String == "CA")
		#expect(event["country"] as? String == "US")
		#expect(event["language"] as? String == "en")
		#expect(event["platform"] as? String == "macOS")
		#expect(event["os_name"] as? String == "macOS")
		#expect(event["os_version"] as? String == "Version 15.0")
		#expect(event["app_version"] as? String == "2.3.0")
		#expect(eventProperties["area"] as? String == "content")
		#expect(eventProperties["session_identifier"] == nil)
		#expect(eventProperties["id"] as? String == "new-item")
		#expect(eventProperties["source"] as? String == "toolbar")
		#expect(eventProperties["enabled"] as? Bool == true)
		#expect(eventProperties["count"] as? Int == 3)
		#expect(eventProperties["ratio"] as? Double == 1.5)
	}

	@Test func send_whenAPIKeyIsMissing_throwsWithoutSendingRequest() async throws {
		let endpoint = try #require(URL(string: "https://example.com/amplitude"))
		let session = AmplitudeSessionMock(
			response: try #require(HTTPURLResponse(url: endpoint, statusCode: 200, httpVersion: nil, headerFields: nil))
		)
		let sut = AmplitudeService(apiKey: " ", endpoint: endpoint, session: session)
		let payload = makePayload()

		await #expect(throws: AmplitudeServiceError.missingAPIKey) {
			try await sut.send([payload])
		}
		#expect(await session.requests.isEmpty)
	}

	@Test func send_whenAmplitudeRejectsRequest_throwsStatusCode() async throws {
		let endpoint = try #require(URL(string: "https://example.com/amplitude"))
		let session = AmplitudeSessionMock(
			data: Data("invalid api key".utf8),
			response: try #require(HTTPURLResponse(url: endpoint, statusCode: 400, httpVersion: nil, headerFields: nil))
		)
		let sut = AmplitudeService(apiKey: "test-api-key", endpoint: endpoint, session: session)
		let payload = makePayload()

		await #expect(throws: AmplitudeServiceError.rejected(statusCode: 400, response: "invalid api key")) {
			try await sut.send([payload])
		}
	}
}

// MARK: - Private methods
private extension AmplitudeServiceTests {

	func makePayload() -> AnalyticsPayload {
		return AnalyticsPayload(
			event: TestEvent(area: "content", name: "button_click"),
			userIdentifier: UUID(),
			sessionIdentifier: UUID(),
			sessionStartedAt: Date()
		)
	}
}

// MARK: - TestEvent
private struct TestEvent {
	let area: String
	let name: String
	let parameters: [String: AnalyticsValue]

	init(area: String, name: String, parameters: [String: AnalyticsValue] = [:]) {
		self.area = area
		self.name = name
		self.parameters = parameters
	}
}

// MARK: - AnalyticsEvent
extension TestEvent: AnalyticsEvent { }

// MARK: - AmplitudeSessionMock
private actor AmplitudeSessionMock: AmplitudeSession {
	private(set) var requests: [URLRequest] = []

	private let data: Data
	private let response: URLResponse

	init(data: Data = Data(), response: URLResponse) {
		self.data = data
		self.response = response
	}

	func data(for request: URLRequest) async throws -> (Data, URLResponse) {
		requests.append(request)
		return (data, response)
	}
}

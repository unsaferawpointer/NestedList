import Testing
import Foundation
@testable import Analytics

struct AnalyticsServiceTests { }

// MARK: - AnalyticsPayloadMetadata
extension AnalyticsServiceTests {

	@Test func analyticsPayloadMetadataEmpty_returnsEmptyMetadata() {
		#expect(AnalyticsPayloadMetadata.empty == AnalyticsPayloadMetadata(
			region: nil,
			country: nil,
			language: nil,
			platform: "",
			osName: "",
			osVersion: "",
			appVersion: nil
		))
	}
}

// MARK: - AnalyticsServiceProtocol
extension AnalyticsServiceTests {

	@Test func track_whenBatchIsNotFull_doesNotSendEventBeforeFlush() async {
		let engine = AnalyticsEngineMock()
		let sut = AnalyticsService(
			engine: engine,
			identityProvider: AnalyticsIdentityProviderMock(),
			metadataProvider: AnalyticsPayloadMetadataProviderMock(),
			queuePolicy: AnalyticsQueuePolicy(batchSize: 2)
		)

		await sut.track(TestEvent(name: .screenShow, parameters: ["source": "dock"]))

		let invocations = await engine.invocations

		#expect(invocations.isEmpty)
	}

	@Test func flush_whenBatchIsNotFull_sendsCachedEvent() async {
		let engine = AnalyticsEngineMock()
		let sut = AnalyticsService(
			engine: engine,
			identityProvider: AnalyticsIdentityProviderMock(),
			metadataProvider: AnalyticsPayloadMetadataProviderMock(),
			queuePolicy: AnalyticsQueuePolicy(batchSize: 2)
		)

		await sut.track(TestEvent(name: .screenShow, parameters: ["source": "dock"]))
		await sut.flush()

		let sentEvents = await engine.invocations.sentEvents

		#expect(sentEvents.map(\.area) == ["test"])
		#expect(sentEvents.map(\.name) == [.screenShow])
		#expect(sentEvents.first?.parameters["source"] == .string("dock"))
	}

	@Test func flush_addsUserAndSessionValuesToPayload() async {
		let userIdentifier = UUID()
		let sessionIdentifier = UUID()
		let sessionStartedAt = Date(timeIntervalSince1970: 123)
		let engine = AnalyticsEngineMock()
		let sut = AnalyticsService(
			engine: engine,
			identityProvider: AnalyticsIdentityProviderMock(
				userIdentifier: userIdentifier,
				sessionIdentifier: sessionIdentifier,
				sessionStartedAt: sessionStartedAt
			),
			metadataProvider: AnalyticsPayloadMetadataProviderMock(),
			queuePolicy: AnalyticsQueuePolicy(batchSize: 2)
		)

		await sut.track(TestEvent(name: .screenShow))
		await sut.flush()

		let sentEvent = await engine.invocations.sentEvents.first

		#expect(sentEvent?.userIdentifier == userIdentifier)
		#expect(sentEvent?.sessionIdentifier == sessionIdentifier)
		#expect(sentEvent?.sessionStartedAt == sessionStartedAt)
	}

	@Test func flush_reusesSessionValuesCapturedAtInitialization() async {
		let identityProvider = IncrementingAnalyticsIdentityProviderMock()
		let engine = AnalyticsEngineMock()
		let sut = AnalyticsService(
			engine: engine,
			identityProvider: identityProvider,
			metadataProvider: AnalyticsPayloadMetadataProviderMock(),
			queuePolicy: AnalyticsQueuePolicy(batchSize: 3)
		)

		await sut.track(TestEvent(name: .buttonClick))
		await sut.track(TestEvent(name: .screenShow))
		await sut.flush()

		let sentEvents = await engine.invocations.sentEvents

		#expect(sentEvents.count == 2)
		#expect(Set(sentEvents.map(\.userIdentifier)).count == 1)
		#expect(Set(sentEvents.map(\.sessionIdentifier)).count == 1)
		#expect(Set(sentEvents.map(\.sessionStartedAt)).count == 1)
	}

	@Test func flush_addsMetadataToPayload() async {
		let metadata = AnalyticsPayloadMetadata(
			region: "CA",
			country: "US",
			language: "en",
			platform: "macOS",
			osName: "macOS",
			osVersion: "Version 15.0",
			appVersion: "2.3.0"
		)
		let engine = AnalyticsEngineMock()
		let sut = AnalyticsService(
			engine: engine,
			identityProvider: AnalyticsIdentityProviderMock(),
			metadataProvider: AnalyticsPayloadMetadataProviderMock(value: metadata),
			queuePolicy: AnalyticsQueuePolicy(batchSize: 2)
		)

		await sut.track(TestEvent(name: .screenShow))
		await sut.flush()

		let sentEvent = await engine.invocations.sentEvents.first

		#expect(sentEvent?.metadata == metadata)
	}

	@Test func track_whenBatchIsFull_sendsBatch() async {
		let engine = AnalyticsEngineMock()
		let sut = AnalyticsService(
			engine: engine,
			identityProvider: AnalyticsIdentityProviderMock(),
			metadataProvider: AnalyticsPayloadMetadataProviderMock(),
			queuePolicy: AnalyticsQueuePolicy(batchSize: 2)
		)

		await sut.track(TestEvent(name: .buttonClick))
		await sut.track(TestEvent(name: .screenShow))

		let sentBatches = await engine.invocations.sentBatches

		#expect(sentBatches.map(\.count) == [2])
		#expect(sentBatches.flatMap { $0 }.map(\.name) == [.buttonClick, .screenShow])
	}

	@Test func flush_whenEngineFails_keepsBatchForNextFlush() async {
		let engine = AnalyticsEngineMock(failureCount: 1)
		let sut = AnalyticsService(
			engine: engine,
			identityProvider: AnalyticsIdentityProviderMock(),
			metadataProvider: AnalyticsPayloadMetadataProviderMock(),
			queuePolicy: AnalyticsQueuePolicy(batchSize: 2)
		)

		await sut.track(TestEvent(name: .buttonClick))
		await sut.track(TestEvent(name: .screenShow))

		let invocationsBeforeRetry = await engine.invocations
		await sut.flush()
		let invocationsAfterRetry = await engine.invocations

		#expect(invocationsBeforeRetry.sentBatches.map { $0.map(\.name) } == [[.buttonClick, .screenShow]])
		#expect(invocationsAfterRetry.sentBatches.map { $0.map(\.name) } == [
			[.buttonClick, .screenShow],
			[.buttonClick, .screenShow]
		])
	}

	@Test func flush_whenCacheContainsMoreThanOneBatch_sendsBatchesInOrder() async {
		let engine = AnalyticsEngineMock()
		let sut = AnalyticsService(
			engine: engine,
			identityProvider: AnalyticsIdentityProviderMock(),
			metadataProvider: AnalyticsPayloadMetadataProviderMock(),
			queuePolicy: AnalyticsQueuePolicy(batchSize: 2)
		)

		await sut.track(TestEvent(name: .buttonClick))
		await sut.track(TestEvent(name: .screenShow))
		await sut.track(TestEvent(name: .toggleClick))
		await sut.flush()

		let sentBatches = await engine.invocations.sentBatches

		#expect(sentBatches.map(\.count) == [2, 1])
		#expect(sentBatches.flatMap { $0 }.map(\.name) == [.buttonClick, .screenShow, .toggleClick])
	}

	@Test func track_whenCacheExceedsLimit_removesOldestEvents() async {
		let engine = AnalyticsEngineMock()
		let sut = AnalyticsService(
			engine: engine,
			identityProvider: AnalyticsIdentityProviderMock(),
			metadataProvider: AnalyticsPayloadMetadataProviderMock(),
			queuePolicy: AnalyticsQueuePolicy(cacheLimit: 2, batchSize: 10)
		)

		await sut.track(TestEvent(name: .buttonClick))
		await sut.track(TestEvent(name: .screenShow))
		await sut.track(TestEvent(name: .toggleClick))
		await sut.flush()

		let sentEvents = await engine.invocations.sentEvents

		#expect(sentEvents.map(\.name) == [.screenShow, .toggleClick])
	}
}

// MARK: - Helpers
private final class IncrementingAnalyticsIdentityProviderMock: @unchecked Sendable {

	var counter: TimeInterval = 1
}

// MARK: - AnalyticsIdentityProviding
extension IncrementingAnalyticsIdentityProviderMock: AnalyticsIdentityProviding {

	var userIdentifier: UUID {
		counter += 1
		return UUID()
	}

	var sessionIdentifier: UUID {
		counter += 1
		return UUID()
	}

	var sessionStartedAt: Date {
		counter += 1
		return Date(timeIntervalSince1970: counter)
	}
}

private extension Array where Element == AnalyticsEngineMock.Action {

	var sentBatches: [[AnalyticsPayload]] {
		return compactMap { action in
			guard case let .send(events) = action else {
				return nil
			}
			return events
		}
	}

	var sentEvents: [AnalyticsPayload] {
		return sentBatches.flatMap { $0 }
	}
}

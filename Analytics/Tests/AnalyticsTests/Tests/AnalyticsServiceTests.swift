import Testing
import Foundation
@testable import Analytics

struct AnalyticsServiceTests { }

// MARK: - AnalyticsServiceProtocol
extension AnalyticsServiceTests {

	@Test func track_whenBatchIsNotFull_doesNotSendEventBeforeFlush() async {
		let engine = AnalyticsEngineMock()
		let sut = AnalyticsService(engine: engine, queuePolicy: AnalyticsQueuePolicy(batchSize: 2))

		await sut.track(TestEvent(name: "app_started", parameters: ["source": "dock"]))

		let invocations = await engine.invocations

		#expect(invocations.isEmpty)
	}

	@Test func flush_whenBatchIsNotFull_sendsCachedEvent() async {
		let engine = AnalyticsEngineMock()
		let sut = AnalyticsService(engine: engine, queuePolicy: AnalyticsQueuePolicy(batchSize: 2))

		await sut.track(TestEvent(name: "app_started", parameters: ["source": "dock"]))
		await sut.flush()

		let sentEvents = await engine.invocations.sentEvents

		#expect(sentEvents.map(\.area) == ["test"])
		#expect(sentEvents.map(\.name) == ["app_started"])
		#expect(sentEvents.first?.parameters["source"] == .string("dock"))
	}

	@Test func flush_addsUserAndSessionIdentifiersToPayload() async {
		let userIdentifier = UUID()
		let sessionIdentifier = UUID()
		let engine = AnalyticsEngineMock()
		let sut = AnalyticsService(
			engine: engine,
			userIdentifier: userIdentifier,
			sessionIdentifier: sessionIdentifier,
			queuePolicy: AnalyticsQueuePolicy(batchSize: 2)
		)

		await sut.track(TestEvent(name: "app_started"))
		await sut.flush()

		let sentEvent = await engine.invocations.sentEvents.first

		#expect(sentEvent?.userIdentifier == userIdentifier)
		#expect(sentEvent?.sessionIdentifier == sessionIdentifier)
	}

	@Test func track_whenBatchIsFull_sendsBatch() async {
		let engine = AnalyticsEngineMock()
		let sut = AnalyticsService(engine: engine, queuePolicy: AnalyticsQueuePolicy(batchSize: 2))

		await sut.track(TestEvent(name: "first"))
		await sut.track(TestEvent(name: "second"))

		let sentBatches = await engine.invocations.sentBatches

		#expect(sentBatches.map(\.count) == [2])
		#expect(sentBatches.flatMap { $0 }.map(\.name) == ["first", "second"])
	}

	@Test func flush_whenEngineFails_keepsBatchForNextFlush() async {
		let engine = AnalyticsEngineMock(failureCount: 1)
		let sut = AnalyticsService(engine: engine, queuePolicy: AnalyticsQueuePolicy(batchSize: 2))

		await sut.track(TestEvent(name: "first"))
		await sut.track(TestEvent(name: "second"))

		let invocationsBeforeRetry = await engine.invocations
		await sut.flush()
		let invocationsAfterRetry = await engine.invocations

		#expect(invocationsBeforeRetry.sentBatches.map { $0.map(\.name) } == [["first", "second"]])
		#expect(invocationsAfterRetry.sentBatches.map { $0.map(\.name) } == [
			["first", "second"],
			["first", "second"]
		])
	}

	@Test func flush_whenCacheContainsMoreThanOneBatch_sendsBatchesInOrder() async {
		let engine = AnalyticsEngineMock()
		let sut = AnalyticsService(engine: engine, queuePolicy: AnalyticsQueuePolicy(batchSize: 2))

		await sut.track(TestEvent(name: "first"))
		await sut.track(TestEvent(name: "second"))
		await sut.track(TestEvent(name: "third"))
		await sut.flush()

		let sentBatches = await engine.invocations.sentBatches

		#expect(sentBatches.map(\.count) == [2, 1])
		#expect(sentBatches.flatMap { $0 }.map(\.name) == ["first", "second", "third"])
	}

	@Test func track_whenCacheExceedsLimit_removesOldestEvents() async {
		let engine = AnalyticsEngineMock()
		let sut = AnalyticsService(engine: engine, queuePolicy: AnalyticsQueuePolicy(cacheLimit: 2, batchSize: 10))

		await sut.track(TestEvent(name: "first"))
		await sut.track(TestEvent(name: "second"))
		await sut.track(TestEvent(name: "third"))
		await sut.flush()

		let sentEvents = await engine.invocations.sentEvents

		#expect(sentEvents.map(\.name) == ["second", "third"])
	}
}

// MARK: - Helpers
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

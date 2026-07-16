import Analytics
import Testing
@testable import CorePresentation

@MainActor struct ItemDetailsViewModelTests { }

// MARK: - Public Interface
@MainActor extension ItemDetailsViewModelTests {

	@Test func show_tracksShowEventOnce() async {
		let analytics = ItemDetailsAnalyticsServiceMock()
		let sut = makeSUT(analytics: analytics)

		sut.show()
		sut.show()

		let event = await analytics.waitForEvent()
		let events = await analytics.trackedEvents()
		#expect(event.name == "item_details_show")
		#expect(events.count == 1)
	}

	@Test func cancel_tracksCancelEventAndCallsCompletionHandler() async {
		let analytics = ItemDetailsAnalyticsServiceMock()
		var result: (properties: ItemDetailsView.Properties, isSuccess: Bool)?
		let sut = makeSUT(analytics: analytics) { properties, isSuccess in
			result = (properties, isSuccess)
		}

		sut.cancel()

		let event = await analytics.waitForEvent()
		#expect(event.name == "item_details_cancel_button_click")
		#expect(result?.properties.text == "Title")
		#expect(result?.properties.description == "Note")
		#expect(result?.isSuccess == false)
	}

	@Test func save_tracksSaveEventAndCallsCompletionHandler() async {
		let analytics = ItemDetailsAnalyticsServiceMock()
		var result: (properties: ItemDetailsView.Properties, isSuccess: Bool)?
		let sut = makeSUT(analytics: analytics) { properties, isSuccess in
			result = (properties, isSuccess)
		}

		sut.save()

		let event = await analytics.waitForEvent()
		#expect(event.name == "item_details_save_button_click")
		#expect(result?.properties.text == "Title")
		#expect(result?.properties.description == "Note")
		#expect(result?.isSuccess == true)
	}
}

// MARK: - Private methods
@MainActor private extension ItemDetailsViewModelTests {

	func makeSUT(
		analytics: ItemDetailsAnalyticsServiceMock,
		completionHandler: @escaping @MainActor (ItemDetailsView.Properties, Bool) -> Void = { _, _ in }
	) -> ItemDetailsViewModel {
		return ItemDetailsViewModel(
			item: .init(
				navigationTitle: "Item Details",
				properties: .init(text: "Title", description: "Note")
			),
			analytics: analytics,
			completionHandler: completionHandler
		)
	}
}

// MARK: - ItemDetailsAnalyticsServiceMock
private actor ItemDetailsAnalyticsServiceMock {
	private var events: [ItemDetailsAnalyticsEvent] = []
	private var eventContinuation: CheckedContinuation<ItemDetailsAnalyticsEvent, Never>?

	func trackedEvents() -> [ItemDetailsAnalyticsEvent] {
		return events
	}

	func waitForEvent() async -> ItemDetailsAnalyticsEvent {
		return await nextEvent()
	}
}

// MARK: - Private methods
private extension ItemDetailsAnalyticsServiceMock {

	func nextEvent() async -> ItemDetailsAnalyticsEvent {
		if let event = events.first {
			return event
		}
		return await withCheckedContinuation { continuation in
			eventContinuation = continuation
		}
	}
}

// MARK: - ConcreteAnalyticsServiceProtocol<ItemDetailsAnalyticsEvent>
extension ItemDetailsAnalyticsServiceMock: ConcreteAnalyticsServiceProtocol<ItemDetailsAnalyticsEvent> {

	func track(_ event: ItemDetailsAnalyticsEvent) async {
		events.append(event)
		eventContinuation?.resume(returning: event)
		eventContinuation = nil
	}
}

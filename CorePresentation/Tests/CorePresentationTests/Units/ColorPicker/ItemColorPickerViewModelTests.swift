import Analytics
import CoreModule
import Testing
@testable import CorePresentation

@MainActor struct ItemColorPickerViewModelTests { }

// MARK: - Public Interface
@MainActor extension ItemColorPickerViewModelTests {

	@Test func show_tracksShowEventOnce() async {
		let analytics = PickerAnalyticsServiceMock()
		let sut = makeSUT(analytics: analytics)

		sut.show()
		sut.show()

		let event = await analytics.waitForEvent()
		let events = await analytics.trackedEvents()
		#expect(event.name == .screenShow)
		#expect(event.area == "color_picker")
		#expect(events.count == 1)
	}

	@Test func selectNone_tracksColorClickWithNoneRawValueAndCallsAction() async {
		let analytics = PickerAnalyticsServiceMock()
		var result: (color: ItemColor?, isSuccess: Bool)?
		let sut = makeSUT(analytics: analytics) { color, isSuccess in
			result = (color, isSuccess)
		}

		sut.selectNone()

		let event = await analytics.waitForEvent()
		#expect(event.name == .buttonClick)
		#expect(event.area == "color_picker")
		#expect(event.parameters["id"] == .string("select_color"))
		#expect(event.parameters["raw_value"] == .string("none"))
		#expect(result?.color == nil)
		#expect(result?.isSuccess == true)
	}

	@Test func select_tracksColorClickWithRawValueAndCallsAction() async {
		let analytics = PickerAnalyticsServiceMock()
		var result: (color: ItemColor?, isSuccess: Bool)?
		let sut = makeSUT(analytics: analytics) { color, isSuccess in
			result = (color, isSuccess)
		}

		sut.select(ColorMapper.map(color: .red))

		let event = await analytics.waitForEvent()
		#expect(event.name == .buttonClick)
		#expect(event.area == "color_picker")
		#expect(event.parameters["id"] == .string("select_color"))
		#expect(event.parameters["raw_value"] == .int(ItemColor.red.rawValue))
		#expect(result?.color == .red)
		#expect(result?.isSuccess == true)
	}

	@Test func cancel_tracksCancelEventAndCallsAction() async {
		let analytics = PickerAnalyticsServiceMock()
		var result: (color: ItemColor?, isSuccess: Bool)?
		let sut = makeSUT(analytics: analytics) { color, isSuccess in
			result = (color, isSuccess)
		}

		sut.cancel()

		let event = await analytics.waitForEvent()
		#expect(event.name == .buttonClick)
		#expect(event.area == "color_picker")
		#expect(event.parameters["id"] == .string("cancel"))
		#expect(result?.color == nil)
		#expect(result?.isSuccess == false)
	}
}

// MARK: - Private methods
@MainActor private extension ItemColorPickerViewModelTests {

	func makeSUT(
		analytics: PickerAnalyticsServiceMock,
		action: @escaping @MainActor (ItemColor?, Bool) -> Void = { _, _ in }
	) -> ItemColorPickerViewModel {
		return ItemColorPickerViewModel(title: "Choose Color", analytics: analytics, action: action)
	}
}

// MARK: - PickerAnalyticsServiceMock
private actor PickerAnalyticsServiceMock {
	private var events: [PickerAnalyticsEvent] = []
	private var eventContinuation: CheckedContinuation<PickerAnalyticsEvent, Never>?

	func trackedEvents() -> [PickerAnalyticsEvent] {
		return events
	}

	func waitForEvent() async -> PickerAnalyticsEvent {
		return await nextEvent()
	}
}

// MARK: - Private methods
private extension PickerAnalyticsServiceMock {

	func nextEvent() async -> PickerAnalyticsEvent {
		if let event = events.first {
			return event
		}
		return await withCheckedContinuation { continuation in
			eventContinuation = continuation
		}
	}
}

// MARK: - PickerAnalyticsServiceProtocol
extension PickerAnalyticsServiceMock: PickerAnalyticsServiceProtocol {

	func track(_ event: PickerAnalyticsEvent) async {
		events.append(event)
		eventContinuation?.resume(returning: event)
		eventContinuation = nil
	}
}

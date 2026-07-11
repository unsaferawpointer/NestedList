import Analytics
import CoreModule
import Testing
@testable import CorePresentation

@MainActor struct IconPickerViewModelTests { }

// MARK: - Public Interface
@MainActor extension IconPickerViewModelTests {

	@Test func show_tracksShowEventOnce() async {
		let analytics = PickerAnalyticsServiceMock()
		let sut = makeSUT(analytics: analytics)

		sut.show()
		sut.show()

		let event = await analytics.waitForEvent()
		let events = await analytics.trackedEvents()
		#expect(event.name == "icon_picker_show")
		#expect(events.count == 1)
	}

	@Test func selectNone_tracksIconClickWithNoneRawValueAndCallsAction() async {
		let analytics = PickerAnalyticsServiceMock()
		var result: (icon: IconName?, isSuccess: Bool)?
		let sut = makeSUT(analytics: analytics) { icon, isSuccess in
			result = (icon, isSuccess)
		}

		sut.selectNone()

		let event = await analytics.waitForEvent()
		#expect(event.name == "icon_click")
		#expect(event.parameters["raw_value"] == .string("none"))
		#expect(result?.icon == nil)
		#expect(result?.isSuccess == true)
	}

	@Test func select_tracksIconClickWithRawValueAndCallsAction() async {
		let analytics = PickerAnalyticsServiceMock()
		var result: (icon: IconName?, isSuccess: Bool)?
		let sut = makeSUT(analytics: analytics) { icon, isSuccess in
			result = (icon, isSuccess)
		}

		sut.select(IconMapper.map(icon: .star))

		let event = await analytics.waitForEvent()
		#expect(event.name == "icon_click")
		#expect(event.parameters["raw_value"] == .int(IconName.star.rawValue))
		#expect(result?.icon == .star)
		#expect(result?.isSuccess == true)
	}

	@Test func cancel_tracksCancelEventAndCallsAction() async {
		let analytics = PickerAnalyticsServiceMock()
		var result: (icon: IconName?, isSuccess: Bool)?
		let sut = makeSUT(analytics: analytics) { icon, isSuccess in
			result = (icon, isSuccess)
		}

		sut.cancel()

		let event = await analytics.waitForEvent()
		#expect(event.name == "icon_picker_cancel_button_click")
		#expect(result?.icon == nil)
		#expect(result?.isSuccess == false)
	}
}

// MARK: - Private methods
@MainActor private extension IconPickerViewModelTests {

	func makeSUT(
		analytics: PickerAnalyticsServiceMock,
		action: @escaping @MainActor (IconName?, Bool) -> Void = { _, _ in }
	) -> IconPickerViewModel {
		return IconPickerViewModel(title: "Choose Icon", analytics: analytics, action: action)
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

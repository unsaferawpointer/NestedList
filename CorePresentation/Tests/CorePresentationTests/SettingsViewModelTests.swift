import Testing
@testable import CorePresentation

@MainActor struct SettingsViewModelTests { }

// MARK: - Public Interface
@MainActor extension SettingsViewModelTests {

	@Test func show_tracksShowEventOnce() async {
		let analytics = SettingsAnalyticsServiceMock()
		let sut = makeSUT(analytics: analytics)

		sut.show()
		sut.show()

		let event = await analytics.waitForEvent()
		let events = await analytics.trackedEvents()
		#expect(event.name == .screenShow)
		#expect(event.area == "settings")
		#expect(events.count == 1)
	}

	@Test func click_tracksButtonClick() async {
		let analytics = SettingsAnalyticsServiceMock()
		let sut = makeSUT(analytics: analytics)

		sut.click(.contactDeveloper)

		let event = await analytics.waitForEvent()
		#expect(event.name == .buttonClick)
		#expect(event.parameters["id"] == .string("contact_developer"))
	}

	@Test func setCompletionBehaviour_whenValueChanged_tracksToggleClick() async {
		let analytics = SettingsAnalyticsServiceMock()
		let sut = makeSUT(analytics: analytics)

		sut.setCompletionBehaviour(isMoveToEnd: true)

		let event = await analytics.waitForEvent()
		#expect(event.name == .toggleClick)
		#expect(event.parameters["id"] == .string("completion_behaviour"))
		#expect(event.parameters["value"] == .bool(true))
		#expect(sut.settings.completionBehaviour == .moveToEnd)
	}

	@Test func setCompletionBehaviour_whenValueIsSame_doesNotTrackAnalytics() async {
		let analytics = SettingsAnalyticsServiceMock()
		let sut = makeSUT(analytics: analytics)

		sut.setCompletionBehaviour(isMoveToEnd: false)

		let events = await analytics.trackedEvents()
		#expect(events.isEmpty)
		#expect(sut.settings.completionBehaviour == .regular)
	}

	@Test func setIconColor_whenValueChanged_tracksDropdownItemClick() async {
		let analytics = SettingsAnalyticsServiceMock()
		let sut = makeSUT(analytics: analytics)

		sut.setIconColor(.primary)

		let event = await analytics.waitForEvent()
		#expect(event.name == .dropdownItemClick)
		#expect(event.parameters["id"] == .string("icon_color"))
		#expect(event.parameters["value"] == .string("primary"))
		#expect(sut.settings.iconColor == .primary)
	}

	@Test func setIconColor_whenValueIsSame_doesNotTrackAnalytics() async {
		let analytics = SettingsAnalyticsServiceMock()
		let sut = makeSUT(analytics: analytics)

		sut.setIconColor(.neutral)

		let events = await analytics.trackedEvents()
		#expect(events.isEmpty)
		#expect(sut.settings.iconColor == .neutral)
	}

	@Test func setSoundEffects_whenValueChanged_tracksToggleClick() async {
		let analytics = SettingsAnalyticsServiceMock()
		let sut = makeSUT(analytics: analytics)

		sut.setSoundEffects(isEnabled: false)

		let event = await analytics.waitForEvent()
		#expect(event.name == .toggleClick)
		#expect(event.parameters["id"] == .string("sound_effects"))
		#expect(event.parameters["value"] == .bool(false))
		#expect(sut.settings.soundEffects == .disabled)
	}

	@Test func setSoundEffects_whenValueIsSame_doesNotTrackAnalytics() async {
		let analytics = SettingsAnalyticsServiceMock()
		let sut = makeSUT(analytics: analytics)

		sut.setSoundEffects(isEnabled: true)

		let events = await analytics.trackedEvents()
		#expect(events.isEmpty)
		#expect(sut.settings.soundEffects == .enabled)
	}
}

// MARK: - Private methods
@MainActor private extension SettingsViewModelTests {

	func makeSUT(analytics: SettingsAnalyticsServiceMock) -> SettingsViewModel {
		let provider = SettingsProvider()
		provider.state = Settings(completionBehaviour: .regular, iconColor: .neutral)
		return SettingsViewModel(provider: provider, analytics: analytics)
	}
}

// MARK: - SettingsAnalyticsServiceMock
private actor SettingsAnalyticsServiceMock {
	private var events: [SettingsAnalyticsEvent] = []
	private var eventContinuation: CheckedContinuation<SettingsAnalyticsEvent, Never>?

	func trackedEvents() -> [SettingsAnalyticsEvent] {
		return events
	}

	func waitForEvent() async -> SettingsAnalyticsEvent {
		return await nextEvent()
	}
}

// MARK: - Private methods
private extension SettingsAnalyticsServiceMock {

	func nextEvent() async -> SettingsAnalyticsEvent {
		if let event = events.first {
			return event
		}
		return await withCheckedContinuation { continuation in
			eventContinuation = continuation
		}
	}
}

// MARK: - SettingsAnalyticsServiceProtocol
extension SettingsAnalyticsServiceMock: SettingsAnalyticsServiceProtocol {

	func track(_ event: SettingsAnalyticsEvent) async {
		events.append(event)
		eventContinuation?.resume(returning: event)
		eventContinuation = nil
	}
}

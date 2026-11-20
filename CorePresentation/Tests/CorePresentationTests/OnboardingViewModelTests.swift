import Testing
@testable import CorePresentation

@MainActor struct OnboardingViewModelTests { }

// MARK: - Public Interface
@MainActor extension OnboardingViewModelTests {

	@Test func show_tracksShowEventOnce() async {
		let analytics = OnboardingAnalyticsMock()
		let sut = makeSUT(analytics: analytics)

		sut.show()
		sut.show()

		let event = await analytics.waitForEvent()
		let events = await analytics.trackedEvents()
		#expect(event.name == .screenShow)
		#expect(event.parameters["total_count"] == .int(2))
		#expect(events.count == 1)
	}

	@Test func primaryAction_whenCanNext_movesForwardWithoutTrackingAnalytics() async {
		let analytics = OnboardingAnalyticsMock()
		let sut = makeSUT(analytics: analytics)

		sut.primaryAction()

		let events = await analytics.trackedEvents()
		#expect(events.isEmpty)
		#expect(sut.currentPage == 1)
		#expect(sut.id == "second")
		#expect(sut.isCompleted == false)
	}

	@Test func primaryAction_whenCannotNext_tracksGetStartedAndCompletes() async {
		let analytics = OnboardingAnalyticsMock()
		let sut = makeSUT(analytics: analytics)
		sut.currentPage = 1

		sut.primaryAction()

		let event = await analytics.waitForEvent()
		#expect(event.name == .buttonClick)
		#expect(event.parameters["id"] == .string("get_started"))
		#expect(event.parameters["index"] == .int(1))
		#expect(sut.currentPage == 1)
		#expect(sut.isCompleted == true)
	}

	@Test func back_whenCanBack_tracksBackAndMovesBack() async {
		let analytics = OnboardingAnalyticsMock()
		let sut = makeSUT(analytics: analytics)
		sut.currentPage = 1

		sut.back()

		let event = await analytics.waitForEvent()
		#expect(event.name == .buttonClick)
		#expect(event.parameters["id"] == .string("back"))
		#expect(event.parameters["index"] == .int(1))
		#expect(sut.currentPage == 0)
		#expect(sut.id == "first")
	}

	@Test func skip_tracksSkipAndCompletes() async {
		let analytics = OnboardingAnalyticsMock()
		let sut = makeSUT(analytics: analytics)

		sut.skip()

		let event = await analytics.waitForEvent()
		#expect(event.name == .buttonClick)
		#expect(event.parameters["id"] == .string("skip"))
		#expect(event.parameters["index"] == .int(0))
		#expect(sut.isCompleted == true)
	}

	@Test func navigation_preservesEachPreparedScenarioWhenReturningToPage() {
		// Arrange
		let sut = makeSUT(analytics: OnboardingAnalyticsMock())
		let firstScenario = sut.feature.scenario
		let secondScenario = sut.features[1].scenario

		// Act
		sut.primaryAction()
		let selectedScenario = sut.feature.scenario
		sut.back()

		// Assert
		#expect(selectedScenario.id == secondScenario.id)
		#expect(sut.feature.scenario.id == firstScenario.id)
		#expect(sut.feature.scenario.steps == firstScenario.steps)
		#expect(!sut.isCompleted)
	}
}

// MARK: - Nested data structs
@MainActor private extension OnboardingViewModelTests {

	func makeSUT(analytics: OnboardingAnalyticsMock) -> OnboardingViewModel {
		return OnboardingViewModel(features: features, analytics: analytics)
	}

	var features: [Onboarding.Feature] {
		[
			.init(
				id: "first",
				title: "First",
				subtitle: "First page",
				scenario: .subitems
			),
			.init(
				id: "second",
				title: "Second",
				subtitle: "Second page",
				scenario: .mirrors
			)
		]
	}
}

// MARK: - OnboardingAnalyticsMock
private actor OnboardingAnalyticsMock {
	private var events: [OnboardingAnalyticsEvent] = []
	private var eventContinuation: CheckedContinuation<OnboardingAnalyticsEvent, Never>?

	func trackedEvents() -> [OnboardingAnalyticsEvent] {
		return events
	}

	func waitForEvent() async -> OnboardingAnalyticsEvent {
		return await nextEvent()
	}
}

// MARK: - Private methods
private extension OnboardingAnalyticsMock {

	func nextEvent() async -> OnboardingAnalyticsEvent {
		if let event = events.first {
			return event
		}
		return await withCheckedContinuation { continuation in
			eventContinuation = continuation
		}
	}
}

// MARK: - ConcreteAnalyticsServiceProtocol<OnboardingAnalyticsEvent>
extension OnboardingAnalyticsMock: ConcreteAnalyticsServiceProtocol<OnboardingAnalyticsEvent> {

	func track(_ event: OnboardingAnalyticsEvent) async {
		events.append(event)
		eventContinuation?.resume(returning: event)
		eventContinuation = nil
	}
}

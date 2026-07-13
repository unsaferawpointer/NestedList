import Analytics
import Testing
@testable import CorePresentation

struct OnboardingAnalyticsEventTests { }

// MARK: - Public Interface
extension OnboardingAnalyticsEventTests {

	@Test func screenShow_hasExpectedSchema() {
		let sut = OnboardingAnalyticsEvent.screenShow(totalCount: 3)

		#expect(sut.area == "onboarding")
		#expect(sut.name == "screen_show")
		#expect(sut.parameters["total_count"] == .int(3))
	}

	@Test func buttonClick_hasExpectedSchema() {
		let cases: [(button: OnboardingAnalyticsEvent.Button, rawValue: String, index: Int)] = [
			(.back, "back", 0),
			(.skip, "skip", 1),
			(.getStarted, "get_started", 2)
		]

		for (button, rawValue, index) in cases {
			let event = OnboardingAnalyticsEvent.buttonClick(button: button, index: index)

			#expect(event.area == "onboarding")
			#expect(event.name == "button_click")
			#expect(event.parameters["button"] == .string(rawValue))
			#expect(event.parameters["index"] == .int(index))
		}
	}
}

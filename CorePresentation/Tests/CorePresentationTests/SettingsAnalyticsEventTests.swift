import Analytics
import Testing
@testable import CorePresentation

struct SettingsAnalyticsEventTests { }

// MARK: - Public Interface
extension SettingsAnalyticsEventTests {

	@Test func screenShow_hasExpectedSchema() {
		let sut = SettingsAnalyticsEvent.screenShow

		#expect(sut.area == "settings")
		#expect(sut.name == .screenShow)
		#expect(sut.parameters.isEmpty)
	}

	@Test func buttonClick_hasExpectedSchema() {
		let cases: [(id: SettingsAnalyticsEvent.ButtonIdentifier, rawValue: String)] = [
			(.rateApp, "rate_app"),
			(.contactDeveloper, "contact_developer")
		]

		for (id, rawValue) in cases {
			let event = SettingsAnalyticsEvent.buttonClick(id: id)

			#expect(event.area == "settings")
			#expect(event.name == .buttonClick)
			#expect(event.parameters["id"] == .string(rawValue))
		}
	}

	@Test func dropdownItemClick_hasExpectedSchema() {
		let sut = SettingsAnalyticsEvent.dropdownItemClick(id: .iconColor, value: "accent")

		#expect(sut.area == "settings")
		#expect(sut.name == .dropdownItemClick)
		#expect(sut.parameters["id"] == .string("icon_color"))
		#expect(sut.parameters["value"] == .string("accent"))
	}

	@Test func toggleClick_hasExpectedSchema() {
		let sut = SettingsAnalyticsEvent.toggleClick(id: .completionBehaviour, value: true)

		#expect(sut.area == "settings")
		#expect(sut.name == .toggleClick)
		#expect(sut.parameters["id"] == .string("completion_behaviour"))
		#expect(sut.parameters["value"] == .bool(true))
	}
}

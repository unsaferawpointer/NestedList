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
		let cases: [(id: SettingsAnalyticsEvent.ControlIdentifier, rawValue: String)] = [
			(.completionBehaviour, "completion_behaviour"),
			(.soundEffects, "sound_effects")
		]

		for (id, rawValue) in cases {
			let event = SettingsAnalyticsEvent.toggleClick(id: id, value: true)

			#expect(event.area == "settings")
			#expect(event.name == .toggleClick)
			#expect(event.parameters["id"] == .string(rawValue))
			#expect(event.parameters["value"] == .bool(true))
		}
	}
}

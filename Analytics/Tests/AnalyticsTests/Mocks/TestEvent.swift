@testable import Analytics

struct TestEvent {

	let area: String
	let name: String
	let parameters: [String: AnalyticsValue]

	init(area: String = "test", name: String, parameters: [String: AnalyticsValue] = [:]) {
		self.area = area
		self.name = name
		self.parameters = parameters
	}
}

// MARK: - AnalyticsEvent
extension TestEvent: AnalyticsEvent { }

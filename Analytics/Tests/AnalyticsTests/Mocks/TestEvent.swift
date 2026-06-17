@testable import Analytics

struct TestEvent: AnalyticsEvent {

	let name: String
	let parameters: [String: AnalyticsValue]

	init(name: String, parameters: [String: AnalyticsValue] = [:]) {
		self.name = name
		self.parameters = parameters
	}
}

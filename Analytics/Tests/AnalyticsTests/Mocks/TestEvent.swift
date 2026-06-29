@testable import Analytics

struct TestEvent {

	let space: String
	let name: String
	let parameters: [String: AnalyticsValue]

	init(space: String = "test", name: String, parameters: [String: AnalyticsValue] = [:]) {
		self.space = space
		self.name = name
		self.parameters = parameters
	}
}

// MARK: - AnalyticsEvent
extension TestEvent: AnalyticsEvent { }

@testable import Analytics

struct AnalyticsPayloadMetadataProviderMock: AnalyticsPayloadMetadataProvider {

	let value: AnalyticsPayloadMetadata

	init(
		value: AnalyticsPayloadMetadata = .empty
	) {
		self.value = value
	}

	func metadata() -> AnalyticsPayloadMetadata {
		return value
	}
}

import Foundation
@testable import Analytics

struct AnalyticsIdentityProviderMock: AnalyticsIdentityProviding {
	let userIdentifier: UUID
	let sessionIdentifier: UUID

	init(
		userIdentifier: UUID = UUID(),
		sessionIdentifier: UUID = UUID()
	) {
		self.userIdentifier = userIdentifier
		self.sessionIdentifier = sessionIdentifier
	}
}

import Foundation
@testable import Analytics

struct AnalyticsIdentityProviderMock: AnalyticsIdentityProviding {
	let userIdentifier: UUID
	let sessionIdentifier: UUID
	let sessionStartedAt: Date

	init(
		userIdentifier: UUID = UUID(),
		sessionIdentifier: UUID = UUID(),
		sessionStartedAt: Date = Date()
	) {
		self.userIdentifier = userIdentifier
		self.sessionIdentifier = sessionIdentifier
		self.sessionStartedAt = sessionStartedAt
	}
}

import Foundation
import Testing
@testable import CorePresentation

struct AnalyticsIdentityProviderTests { }

// MARK: - userIdentifier
extension AnalyticsIdentityProviderTests {

	@Test func userIdentifier_whenValueIsMissing_createsAndStoresIdentifier() throws {
		let defaults = try makeDefaults()
		let sut = AnalyticsIdentityProvider(defaults: defaults)

		let identifier = sut.userIdentifier

		#expect(defaults.string(forKey: "analytics.userIdentifier") == identifier.uuidString)
	}

	@Test func userIdentifier_whenValueExists_returnsStoredIdentifier() throws {
		let defaults = try makeDefaults()
		let identifier = UUID()
		defaults.set(identifier.uuidString, forKey: "analytics.userIdentifier")
		let sut = AnalyticsIdentityProvider(defaults: defaults)

		#expect(sut.userIdentifier == identifier)
	}

	@Test func userIdentifier_whenValueIsInvalid_replacesStoredValue() throws {
		let defaults = try makeDefaults()
		defaults.set("invalid", forKey: "analytics.userIdentifier")
		let sut = AnalyticsIdentityProvider(defaults: defaults)

		let identifier = sut.userIdentifier

		#expect(defaults.string(forKey: "analytics.userIdentifier") == identifier.uuidString)
	}
}

// MARK: - Private methods
private extension AnalyticsIdentityProviderTests {

	func makeDefaults() throws -> UserDefaults {
		let suiteName = "AnalyticsIdentityProviderTests.\(UUID().uuidString)"
		let defaults = try #require(UserDefaults(suiteName: suiteName))
		defaults.removePersistentDomain(forName: suiteName)
		return defaults
	}
}

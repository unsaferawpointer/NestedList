//
//  AnalyticsIdentityProvider.swift
//  CorePresentation
//

import Foundation
import Analytics

/// Provides stable anonymous analytics identity values.
///
/// The user identifier is stored in `UserDefaults` and reused across application launches. The
/// session values are generated once per process and reused until the app is closed.
public final class AnalyticsIdentityProvider: @unchecked Sendable {

	// MARK: - Constants

	private static let sessionIdentifier = UUID()
	private static let sessionStartedAt = Date()

	private let userIdentifierKey: String

	// MARK: - DI

	private let defaults: UserDefaults

	// MARK: - Initialization

	/// Creates a provider backed by the shared application `UserDefaults` store.
	public convenience init() {
		self.init(defaults: .standard)
	}

	init(defaults: UserDefaults, userIdentifierKey: String = "analytics.userIdentifier") {
		self.defaults = defaults
		self.userIdentifierKey = userIdentifierKey
	}
}

// MARK: - AnalyticsIdentityProviding
extension AnalyticsIdentityProvider: AnalyticsIdentityProviding {

	/// Stable anonymous identifier associated with the current app installation.
	public var userIdentifier: UUID {
		return getStoredUserIdentifier()
	}

	/// Identifier associated with the current app process.
	public var sessionIdentifier: UUID {
		return Self.sessionIdentifier
	}

	/// Start date associated with the current app process.
	public var sessionStartedAt: Date {
		return Self.sessionStartedAt
	}
}

// MARK: - Private methods
private extension AnalyticsIdentityProvider {

	func getStoredUserIdentifier() -> UUID {
		if let rawValue = defaults.string(forKey: userIdentifierKey),
		   let storedIdentifier = UUID(uuidString: rawValue) {
			return storedIdentifier
		}

		let identifier = UUID()
		defaults.set(identifier.uuidString, forKey: userIdentifierKey)
		return identifier
	}
}

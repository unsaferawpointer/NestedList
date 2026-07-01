//
//  AnalyticsIdentityProvider.swift
//  CorePresentation
//

import Foundation

/// Provides a stable anonymous user identifier for analytics events.
///
/// The provider stores the identifier in `UserDefaults` and reuses it across application launches.
/// If no identifier exists, or the stored value is not a valid UUID string, a new identifier is
/// generated and persisted before being returned.
public final class AnalyticsIdentityProvider {

	// MARK: - Constants

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

extension AnalyticsIdentityProvider {

	/// Stable anonymous identifier associated with the current app installation.
	public var userIdentifier: UUID {
		return getStoredUserIdentifier()
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

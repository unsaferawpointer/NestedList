//
//  AnalyticsIdentityProviding.swift
//  Analytics
//

import Foundation

/// Provides identifiers associated with analytics events.
public protocol AnalyticsIdentityProviding: Sendable {

	/// Stable identifier of the user associated with tracked events.
	var userIdentifier: UUID { get }

	/// Identifier of the current analytics session.
	var sessionIdentifier: UUID { get }
}

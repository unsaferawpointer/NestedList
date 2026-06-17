//
//  AnalyticsEvent.swift
//  Analytics
//

import Foundation

/// A typed analytics event that can be tracked by `AnalyticsService`.
///
/// Define one conforming type per meaningful user or application event. This keeps event
/// names and parameters close to the call site while still allowing the service to handle
/// all events through one common interface.
public protocol AnalyticsEvent: Sendable {

	/// Stable event name used by the analytics backend.
	var name: String { get }

	/// Additional typed values associated with the event.
	var parameters: [String: AnalyticsValue] { get }
}

public extension AnalyticsEvent {

	/// Default empty parameter set for events that only need a name.
	var parameters: [String: AnalyticsValue] {
		return [:]
	}
}

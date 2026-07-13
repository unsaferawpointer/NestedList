//
//  OnboardingAnalyticsEvent.swift
//  CorePresentation
//
//  Created by Codex on 13.07.2026.
//

import Analytics

/// Analytics events produced by the onboarding screen.
public enum OnboardingAnalyticsEvent {

	/// Onboarding became visible to the user.
	///
	/// - Parameter totalCount: Number of onboarding pages.
	case screenShow(totalCount: Int)

	/// User clicked an onboarding button.
	case buttonClick(button: Button, index: Int)
}

// MARK: - Nested types
public extension OnboardingAnalyticsEvent {

	enum Button: String, Sendable {
		case back
		case skip
		case getStarted = "get_started"
	}
}

// MARK: - AnalyticsEvent
extension OnboardingAnalyticsEvent: AnalyticsEvent {

	public var area: String { "onboarding" }

	public var name: String {
		switch self {
		case .screenShow:
			"screen_show"
		case .buttonClick:
			"button_click"
		}
	}

	public var parameters: [String: AnalyticsValue] {
		switch self {
		case let .screenShow(totalCount):
			[
				"total_count": .int(totalCount)
			]
		case let .buttonClick(button, index):
			[
				"button": .string(button.rawValue),
				"index": .int(index)
			]
		}
	}
}

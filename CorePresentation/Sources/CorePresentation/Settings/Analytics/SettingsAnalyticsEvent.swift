//
//  SettingsAnalyticsEvent.swift
//  CorePresentation
//
//  Created by Codex on 13.07.2026.
//

import Analytics

/// Analytics events produced by the settings screen.
public enum SettingsAnalyticsEvent {

	/// Settings screen became visible to the user.
	case screenShow

	/// User clicked a settings screen button.
	case buttonClick(id: ButtonIdentifier)

	/// User selected an item from a settings dropdown.
	case dropdownItemClick(id: ControlIdentifier, value: String)

	/// User clicked a settings toggle.
	case toggleClick(id: ControlIdentifier, value: Bool)
}

// MARK: - Nested types
public extension SettingsAnalyticsEvent {

	enum ButtonIdentifier: String, Sendable {
		case rateApp = "rate_app"
		case contactDeveloper = "contact_developer"
	}

	enum ControlIdentifier: String, Sendable {
		case completionBehaviour = "completion_behaviour"
		case iconColor = "icon_color"
	}
}

// MARK: - AnalyticsEvent
extension SettingsAnalyticsEvent: AnalyticsEvent {

	public var area: String { "settings" }

	public var name: String {
		switch self {
		case .screenShow:
			"screen_show"
		case .buttonClick:
			"button_click"
		case .dropdownItemClick:
			"dropdown_item_click"
		case .toggleClick:
			"toggle_click"
		}
	}

	public var parameters: [String: AnalyticsValue] {
		switch self {
		case .screenShow:
			[:]
		case let .buttonClick(id):
			[
				"id": .string(id.rawValue)
			]
		case let .dropdownItemClick(id, value):
			[
				"id": .string(id.rawValue),
				"value": .string(value)
			]
		case let .toggleClick(id, value):
			[
				"id": .string(id.rawValue),
				"value": .bool(value)
			]
		}
	}
}

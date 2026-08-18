//
//  ColumnAnalyticsEvent.swift
//  macOS
//

import Analytics

/// Analytics events produced by the Column unit.
enum ColumnAnalyticsEvent {
	case menuItemClick(id: String)
}

// MARK: - AnalyticsEvent
extension ColumnAnalyticsEvent: AnalyticsEvent {

	var area: String { "column" }

	var name: AnalyticsEventName {
		.menuItemClick
	}

	var parameters: [String: AnalyticsValue] {
		switch self {
		case let .menuItemClick(id):
			[
				"id": .string(id)
			]
		}
	}
}

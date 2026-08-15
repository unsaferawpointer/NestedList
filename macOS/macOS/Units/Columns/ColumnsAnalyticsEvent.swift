//
//  ColumnsAnalyticsEvent.swift
//  macOS
//

import Analytics

/// Analytics events produced by the Columns unit.
enum ColumnsAnalyticsEvent {
	case buttonClick(id: String)
	case screenShow
}

// MARK: - AnalyticsEvent
extension ColumnsAnalyticsEvent: AnalyticsEvent {

	var area: String { "columns" }

	var name: AnalyticsEventName {
		switch self {
		case .buttonClick:
			.buttonClick
		case .screenShow:
			.screenShow
		}
	}

	var parameters: [String: AnalyticsValue] {
		switch self {
		case let .buttonClick(id):
			[
				"id": .string(id)
			]
		case .screenShow:
			[:]
		}
	}
}

//
//  ReorderAnalyticsEvent.swift
//  iOS
//
//  Created by Codex on 13.07.2026.
//

import Analytics

/// Analytics events produced by the reorder screen.
enum ReorderAnalyticsEvent {

	/// Reorder screen became visible to the user.
	///
	/// - Parameter itemsCount: Number of reorderable sibling items shown on the screen.
	case show(itemsCount: Int)

	/// User clicked the close button.
	case closeButtonClick

	/// User moved items through the reorder list drag control.
	///
	/// - Parameter itemsCount: Number of moved items.
	case dragDropMove(itemsCount: Int)
}

// MARK: - AnalyticsEvent
extension ReorderAnalyticsEvent: AnalyticsEvent {

	var area: String { "reorder" }

	var name: AnalyticsEventName {
		switch self {
		case .show:					.screenShow
		case .closeButtonClick:		.buttonClick
		case .dragDropMove:			.dragDropMove
		}
	}

	var parameters: [String: AnalyticsValue] {
		switch self {
		case let .show(itemsCount):
			[
				"items_count": .int(itemsCount)
			]
		case .closeButtonClick:
			[
				"id": .string("close")
			]
		case let .dragDropMove(itemsCount):
			[
				"items_count": .int(itemsCount)
			]
		}
	}
}

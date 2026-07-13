//
//  TargetDestinationAnalyticsEvent.swift
//  iOS
//
//  Created by Codex on 13.07.2026.
//

import Analytics

/// Analytics events produced by the target destination screen.
enum TargetDestinationAnalyticsEvent {

	/// Target destination screen became visible to the user.
	///
	/// - Parameters:
	///   - availableItemsCount: Number of selectable target items.
	///   - unavailableItemsCount: Number of disabled target items.
	case targetDestinationShow(availableItemsCount: Int, unavailableItemsCount: Int)

	/// User selected the root destination.
	case rootDestinationClick

	/// User selected an item destination.
	case itemDestinationClick

	/// User clicked the target destination close button.
	case closeButtonClick
}

// MARK: - AnalyticsEvent
extension TargetDestinationAnalyticsEvent: AnalyticsEvent {

	var area: String { "target_destination" }

	var name: AnalyticsEventName {
		switch self {
		case .targetDestinationShow:
			.screenShow
		case .rootDestinationClick, .itemDestinationClick, .closeButtonClick:
			.buttonClick
		}
	}

	var parameters: [String: AnalyticsValue] {
		switch self {
		case let .targetDestinationShow(availableItemsCount, unavailableItemsCount):
			[
				"available_items_count": .int(availableItemsCount),
				"unavailable_items_count": .int(unavailableItemsCount)
			]
		case .rootDestinationClick:
			[
				"id": .string("select_root")
			]
		case .itemDestinationClick:
			[
				"id": .string("select_item")
			]
		case .closeButtonClick:
			[
				"id": .string("close")
			]
		}
	}
}

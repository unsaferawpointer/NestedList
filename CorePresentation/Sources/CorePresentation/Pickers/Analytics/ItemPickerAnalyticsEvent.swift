//
//  ItemPickerAnalyticsEvent.swift
//  CorePresentation
//

import Analytics

/// Analytics events produced by the reusable item picker.
public enum ItemPickerAnalyticsEvent {

	/// Item picker became visible to the user.
	case itemPickerShow(itemsCount: Int)

	/// User selected an item.
	case itemClick

	/// User clicked the item picker cancel button.
	case cancelButtonClick
}

// MARK: - AnalyticsEvent
extension ItemPickerAnalyticsEvent: AnalyticsEvent {

	public var area: String { "item_picker" }

	public var name: AnalyticsEventName {
		switch self {
		case .itemPickerShow:
			.screenShow
		case .itemClick, .cancelButtonClick:
			.buttonClick
		}
	}

	public var parameters: [String: AnalyticsValue] {
		switch self {
		case let .itemPickerShow(itemsCount):
			[
				"items_count": .int(itemsCount)
			]
		case .itemClick:
			[
				"id": .string("select_item")
			]
		case .cancelButtonClick:
			[
				"id": .string("cancel")
			]
		}
	}
}

//
//  ItemDetailsAnalyticsEvent.swift
//  CorePresentation
//
//  Created by Anton Cherkasov on 12.07.2026.
//

import Analytics

/// Analytics events produced by the item details screen.
public enum ItemDetailsAnalyticsEvent {

	/// Item details screen became visible to the user.
	case itemDetailsShow

	/// User clicked the item details cancel button.
	case itemDetailsCancelButtonClick

	/// User clicked the item details save button.
	case itemDetailsSaveButtonClick
}

// MARK: - AnalyticsEvent
extension ItemDetailsAnalyticsEvent: AnalyticsEvent {

	public var area: String { "item_details" }

	public var name: String {
		switch self {
		case .itemDetailsShow:
			"item_details_show"
		case .itemDetailsCancelButtonClick:
			"item_details_cancel_button_click"
		case .itemDetailsSaveButtonClick:
			"item_details_save_button_click"
		}
	}
}

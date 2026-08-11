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
	///
	/// - Parameters:
	///   - initialTextLength: Length of the text when the screen was opened.
	///   - mode: Whether the screen was opened to create or edit an item.
	case itemDetailsShow(initialTextLength: Int, mode: ItemDetailsView.Mode)

	/// User clicked the item details cancel button.
	case itemDetailsCancelButtonClick

	/// User clicked the item details save button.
	case itemDetailsSaveButtonClick
}

// MARK: - AnalyticsEvent
extension ItemDetailsAnalyticsEvent: AnalyticsEvent {

	public var area: String { "item_details" }

	public var name: AnalyticsEventName {
		switch self {
		case .itemDetailsShow:
			.screenShow
		case .itemDetailsCancelButtonClick, .itemDetailsSaveButtonClick:
			.buttonClick
		}
	}

	public var parameters: [String: AnalyticsValue] {
		switch self {
		case let .itemDetailsShow(initialTextLength, mode):
			[
				"initial_text_length": .int(initialTextLength),
				"mode": .string(mode.rawValue)
			]
		case .itemDetailsCancelButtonClick:
			[
				"id": .string("cancel")
			]
		case .itemDetailsSaveButtonClick:
			[
				"id": .string("save")
			]
		}
	}
}

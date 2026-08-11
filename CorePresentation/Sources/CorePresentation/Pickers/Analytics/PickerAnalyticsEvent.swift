//
//  PickerAnalyticsEvent.swift
//  CorePresentation
//
//  Created by Anton Cherkasov on 11.07.2026.
//

import Analytics

/// Analytics events produced by picker screens.
public enum PickerAnalyticsEvent {

	/// Icon picker became visible to the user.
	case iconPickerShow

	/// Color picker became visible to the user.
	case colorPickerShow

	/// User clicked the icon picker cancel button.
	case iconPickerCancelButtonClick

	/// User clicked the color picker cancel button.
	case colorPickerCancelButtonClick

	/// User selected an icon from the icon picker.
	///
	/// - Parameter rawValue: Selected `IconName.rawValue`, or `nil` for none.
	case iconClick(rawValue: Int?)

	/// User selected a color from the color picker.
	///
	/// - Parameter rawValue: Selected `ItemColor.rawValue`, or `nil` for none.
	case colorClick(rawValue: Int?)
}

// MARK: - AnalyticsEvent
extension PickerAnalyticsEvent: AnalyticsEvent {

	public var area: String {
		switch self {
		case .iconPickerShow, .iconPickerCancelButtonClick, .iconClick:
			"icon_picker"
		case .colorPickerShow, .colorPickerCancelButtonClick, .colorClick:
			"color_picker"
		}
	}

	public var name: AnalyticsEventName {
		switch self {
		case .iconPickerShow, .colorPickerShow:
			.screenShow
		case .iconPickerCancelButtonClick, .colorPickerCancelButtonClick, .iconClick, .colorClick:
			.buttonClick
		}
	}

	public var parameters: [String: AnalyticsValue] {
		switch self {
		case .iconPickerShow, .colorPickerShow:
			[:]
		case .iconPickerCancelButtonClick, .colorPickerCancelButtonClick:
			[
				"id": .string("cancel")
			]
		case let .iconClick(rawValue):
			[
				"id": .string("select_icon"),
				"raw_value": rawValue.map(AnalyticsValue.int) ?? .string("none")
			]
		case let .colorClick(rawValue):
			[
				"id": .string("select_color"),
				"raw_value": rawValue.map(AnalyticsValue.int) ?? .string("none")
			]
		}
	}
}

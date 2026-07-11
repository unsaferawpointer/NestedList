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

	public var area: String { "pickers" }

	public var name: String {
		switch self {
		case .iconPickerShow:
			"icon_picker_show"
		case .colorPickerShow:
			"color_picker_show"
		case .iconPickerCancelButtonClick:
			"icon_picker_cancel_button_click"
		case .colorPickerCancelButtonClick:
			"color_picker_cancel_button_click"
		case .iconClick:
			"icon_click"
		case .colorClick:
			"color_click"
		}
	}

	public var parameters: [String: AnalyticsValue] {
		switch self {
		case .iconPickerShow, .colorPickerShow, .iconPickerCancelButtonClick, .colorPickerCancelButtonClick:
			[:]
		case let .iconClick(rawValue), let .colorClick(rawValue):
			[
				"raw_value": rawValue.map(AnalyticsValue.int) ?? .string("none")
			]
		}
	}
}

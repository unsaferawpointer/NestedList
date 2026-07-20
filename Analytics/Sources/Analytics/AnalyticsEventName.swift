//
//  AnalyticsEventName.swift
//  Analytics
//

/// Stable event names supported by the analytics schema.
public enum AnalyticsEventName: String, Sendable {
	case buttonClick = "button_click"
	case menuItemClick = "menu_item_click"
	case dropdownItemClick = "dropdown_item_click"
	case toggleClick = "toggle_click"
	case screenShow = "screen_show"
	case dragDropMove = "drag_drop_move"
	case dragDropCopy = "drag_drop_copy"
	case dragDropInsert = "drag_drop_insert"
	case documentReadError = "document_read_error"
}

//
//  MenuLocalization.swift
//  Nested List
//
//  Created by Anton Cherkasov on 12.04.2025.
//

import Foundation

struct MenuLocalization { }

// MARK: - Strings
extension MenuLocalization {

	static var editorMenuTitle: String {
		String(localized: "editor-menu-title", table: "MenuLocalizable")
	}

	static var newItemTitle: String {
		String(localized: "new-item-title", table: "MenuLocalizable")
	}
	
	static var propertiesHeaderTitle: String {
		String(localized: "properties-header-title", table: "MenuLocalizable")
	}
	
	static var strikethroughItemTitle: String {
		String(localized: "strikethrough-item-title", table: "MenuLocalizable")
	}

	static var displayAsItemTitle: String {
		String(localized: "display-as-item-title", table: "MenuLocalizable")
	}

	static var appearanceHeaderItemTitle: String {
		String(localized: "appearance-header-item-title", table: "MenuLocalizable")
	}

	static var iconItemTitle: String {
		String(localized: "icon-item-title", table: "MenuLocalizable")
	}

	static var colorItemTitle: String {
		String(localized: "color-item-title", table: "MenuLocalizable")
	}

	static var noteItemTitle: String {
		String(localized: "note-item-title", table: "MenuLocalizable")
	}
	
	static var deleteItemTitle: String {
		String(localized: "delete-item-title", table: "MenuLocalizable")
	}

	static var plainItemTitle: String {
		String(localized: "plain-item-item-title", table: "MenuLocalizable")
	}

	static var noIconItemTitle: String {
		String(localized: "no-icon-item-title", table: "MenuLocalizable")
	}

	static var noColorItemTitle: String {
		String(localized: "no-color-item-title", table: "MenuLocalizable")
	}

	static var editItemTitle: String {
		String(localized: "edit-item-title", table: "MenuLocalizable")
	}
}

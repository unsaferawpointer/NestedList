//
//  MenuLocalization.swift
//  Nested List
//
//  Created by Anton Cherkasov on 12.04.2025.
//

import Foundation

protocol MenuLocalizationProtocol {
	var editorMenuTitle: String { get }
	var newItemTitle: String { get }
	var propertiesHeaderTitle: String { get }
	var strikethroughItemTitle: String { get }
	var markedItemTitle: String { get }
	var noteItemTitle: String { get }
	var deleteItemTitle: String { get }
	var displayAsItemTitle: String { get }
	var plainItemTitle: String { get }
	var sectionItemTitle: String { get }
}

final class MenuLocalization { }

// MARK: - MenuLocalizationProtocol
extension MenuLocalization: MenuLocalizationProtocol {

	var editorMenuTitle: String {
		String(localized: "editor-menu-title", table: "MenuLocalizable")
	}

	var newItemTitle: String {
		String(localized: "new-item-title", table: "MenuLocalizable")
	}
	
	var propertiesHeaderTitle: String {
		String(localized: "properties-header-title", table: "MenuLocalizable")
	}
	
	var strikethroughItemTitle: String {
		String(localized: "strikethrough-item-title", table: "MenuLocalizable")
	}
	
	var markedItemTitle: String {
		String(localized: "marked-item-title", table: "MenuLocalizable")
	}
	
	var displayAsItemTitle: String {
		String(localized: "display-as-item-title", table: "MenuLocalizable")
	}

	var iconItemTitle: String {
		String(localized: "icon-item-title", table: "MenuLocalizable")
	}

	var noteItemTitle: String {
		String(localized: "note-item-title", table: "MenuLocalizable")
	}
	
	var deleteItemTitle: String {
		String(localized: "delete-item-title", table: "MenuLocalizable")
	}

	var plainItemTitle: String {
		String(localized: "plain-item-item-title", table: "MenuLocalizable")
	}

	var sectionItemTitle: String {
		String(localized: "section-item-title", table: "MenuLocalizable")
	}
}

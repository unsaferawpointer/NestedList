//
//  MenuLocalization.swift
//  iOS
//
//  Created by Anton Cherkasov on 06.04.2025.
//

protocol MenuLocalizationProtocol {
	var cutItemTitle: String { get }
	var copyItemTitle: String { get }
	var pasteItemTitle: String { get }
	var editItemTitle: String { get }
	var newItemTitle: String { get }
	var completedItemTitle: String { get }
	var markedItemTitle: String { get }
	var sectionItemTitle: String { get }
	var deleteItemTitle: String { get }
}

final class MenuLocalization { }

// MARK: - MenuLocalizationProtocol
extension MenuLocalization: MenuLocalizationProtocol {

	var cutItemTitle: String {
		String(localized: "cut_menu_item_title", table: "MenuLocalizable")
	}
	
	var copyItemTitle: String {
		String(localized: "copy_menu_item_title", table: "MenuLocalizable")
	}
	
	var pasteItemTitle: String {
		String(localized: "paste_menu_item_title", table: "MenuLocalizable")
	}
	
	var editItemTitle: String {
		String(localized: "edit_menu_item_title", table: "MenuLocalizable")
	}
	
	var newItemTitle: String {
		String(localized: "new_menu_item_title", table: "MenuLocalizable")
	}
	
	var completedItemTitle: String {
		String(localized: "completed_menu_item_title", table: "MenuLocalizable")
	}
	
	var markedItemTitle: String {
		String(localized: "marked_menu_item_title", table: "MenuLocalizable")
	}
	
	var sectionItemTitle: String {
		String(localized: "section_menu_item_title", table: "MenuLocalizable")
	}
	
	var deleteItemTitle: String {
		String(localized: "delete_menu_item_title", table: "MenuLocalizable")
	}
}

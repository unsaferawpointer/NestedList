//
//  ToolbarLocalization.swift
//  iOS
//
//  Created by Anton Cherkasov on 06.04.2025.
//

protocol ToolbarLocalizationProtocol {
	var selectItemTitle: String { get }
	var reorderItemTitle: String { get }
	var settingsItemTitle: String { get }
	var doneItemTitle: String { get }
	var expandAllItemTitle: String { get }
	var collapseAllItemTitle: String { get }

	var cutItemTitle: String { get }
	var copyItemTitle: String { get }
	var pasteItemTitle: String { get }
	var strikethroughItemTitle: String { get }
	var markedItemTitle: String { get }
	var sectionItemTitle: String { get }
	var deleteItemTitle: String { get }
}

final class ToolbarLocalization { }

// MARK: - ToolbarLocalizationProtocol
extension ToolbarLocalization: ToolbarLocalizationProtocol {

	var selectItemTitle: String {
		String(localized: "select_toolbar_item_title", table: "ToolbarLocalizable")
	}
	
	var reorderItemTitle: String {
		String(localized: "reorder_toolbar_item_title", table: "ToolbarLocalizable")
	}
	
	var settingsItemTitle: String {
		String(localized: "settings_toolbar_item_title", table: "ToolbarLocalizable")
	}

	var doneItemTitle: String {
		String(localized: "done_toolbar_item_title", table: "ToolbarLocalizable")
	}

	var cutItemTitle: String {
		String(localized: "cut_menu_item_title", table: "ToolbarLocalizable")
	}

	var copyItemTitle: String {
		String(localized: "copy_menu_item_title", table: "ToolbarLocalizable")
	}

	var pasteItemTitle: String {
		String(localized: "paste_menu_item_title", table: "ToolbarLocalizable")
	}

	var strikethroughItemTitle: String {
		String(localized: "strikethrough_menu_item_title", table: "ToolbarLocalizable")
	}

	var markedItemTitle: String {
		String(localized: "marked_menu_item_title", table: "ToolbarLocalizable")
	}

	var sectionItemTitle: String {
		String(localized: "section_menu_item_title", table: "ToolbarLocalizable")
	}

	var deleteItemTitle: String {
		String(localized: "delete_menu_item_title", table: "ToolbarLocalizable")
	}

	var expandAllItemTitle: String {
		String(localized: "expand_all_menu_item_title", table: "ToolbarLocalizable")
	}

	var collapseAllItemTitle: String {
		String(localized: "collapse_all_menu_item_title", table: "ToolbarLocalizable")
	}
}

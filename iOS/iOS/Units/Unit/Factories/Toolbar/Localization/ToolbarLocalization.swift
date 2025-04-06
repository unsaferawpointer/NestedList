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
}

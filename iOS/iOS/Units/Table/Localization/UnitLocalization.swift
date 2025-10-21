//
//  UnitLocalization.swift
//  iOS
//
//  Created by Anton Cherkasov on 16.04.2025.
//

import Foundation

protocol UnitLocalizationProtocol {
	var newItemNavigationTitle: String { get }
	var editItemNavigationTitle: String { get }
}

final class UnitLocalization { }

// MARK: - UnitLocalizationProtocol
extension UnitLocalization: UnitLocalizationProtocol {

	var newItemNavigationTitle: String {
		String(localized: "new_item_navigation_title", table: "UnitLocalizable")
	}
	
	var editItemNavigationTitle: String {
		String(localized: "edit_item_navigation_title", table: "UnitLocalizable")
	}
}

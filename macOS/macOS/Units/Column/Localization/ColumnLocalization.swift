//
//  ColumnLocalization.swift
//  Nested List
//
//  Created by Anton Cherkasov on 14.08.2026.
//

import Foundation

protocol ColumnLocalizationProtocol {
	var newItemDetailsTitle: String { get }
	var editItemDetailsTitle: String { get }
	var newItemText: String { get }
}

// MARK: - ColumnLocalizationProtocol
final class ColumnLocalization: ColumnLocalizationProtocol {

	var newItemText: String {
		return String(localized: "new-item-text", table: "ColumnLocalizable")
	}

	var newItemDetailsTitle: String {
		return String(localized: "new-item-details-title", table: "ColumnLocalizable")
	}

	var editItemDetailsTitle: String {
		return String(localized: "edit-item-details-title", table: "ColumnLocalizable")
	}
}


//
//  ColumnLocalization.swift
//  Nested List
//
//  Created by Anton Cherkasov on 30.08.2025.
//

import Foundation

protocol ColumnLocalizationProtocol {
	var newItemDetailsTitle: String { get }
	var editItemDetailsTitle: String { get }
}

// MARK: - ColumnLocalizationProtocol
final class ColumnLocalization: ColumnLocalizationProtocol {

	var newItemDetailsTitle: String {
		return String(localized: "new-item-details-title", table: "ColumnLocalizable")
	}

	var editItemDetailsTitle: String {
		return String(localized: "edit-item-details-title", table: "ColumnLocalizable")
	}
}

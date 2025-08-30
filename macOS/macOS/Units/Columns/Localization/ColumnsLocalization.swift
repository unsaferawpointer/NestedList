//
//  ColumnsLocalization.swift
//  Nested List
//
//  Created by Anton Cherkasov on 25.08.2025.
//

import Foundation

protocol ColumnsLocalizationProtocol {
	var newItemText: String { get }
	var editItemText: String { get }
	var placeholderTitle: String { get }
	var placeholderDescription: String { get }
}

// MARK: - ColumnsLocalizationProtocol
final class ColumnsLocalization: ColumnsLocalizationProtocol {

	var newItemText: String {
		return String(localized: "new-item-text", table: "ColumnsLocalizable")
	}

	var editItemText: String {
		return String(localized: "edit-item-text", table: "ColumnsLocalizable")
	}

	var placeholderTitle: String {
		return String(localized: "placeholder-title", table: "ColumnsLocalizable")
	}

	var placeholderDescription: String {
		return String(localized: "placeholder-description", table: "ColumnsLocalizable")
	}
}

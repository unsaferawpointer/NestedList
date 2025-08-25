//
//  ColumnsLocalization.swift
//  Nested List
//
//  Created by Anton Cherkasov on 25.08.2025.
//

import Foundation

protocol ColumnsLocalizationProtocol {
	var newItemText: String { get }
}

// MARK: - ColumnsLocalizationProtocol
final class ColumnsLocalization: ColumnsLocalizationProtocol {

	var newItemText: String {
		return String(localized: "new-item-text", table: "ColumnsLocalizable")
	}
}

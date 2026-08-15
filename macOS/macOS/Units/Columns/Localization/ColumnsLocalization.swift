//
//  ColumnsLocalization.swift
//  macOS
//

import Foundation

protocol ColumnsLocalizationProtocol {
	var newItemText: String { get }
	var placeholderTitle: String { get }
	var placeholderDescription: String { get }
	var newItemToolbarItemLabel: String { get }
}

// MARK: - ColumnsLocalizationProtocol
final class ColumnsLocalization: ColumnsLocalizationProtocol {

	var newItemText: String {
		return String(localized: "new-item-text", table: "ColumnsLocalizable")
	}

	var placeholderTitle: String {
		return String(localized: "placeholder-title", table: "ColumnsLocalizable")
	}

	var placeholderDescription: String {
		return String(localized: "placeholder-description", table: "ColumnsLocalizable")
	}

	var newItemToolbarItemLabel: String {
		return String(localized: "new-item-toolbar-item-label", table: "ColumnsLocalizable")
	}
}

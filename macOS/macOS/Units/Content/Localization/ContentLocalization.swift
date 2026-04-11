//
//  ContentLocalization.swift
//  Nested List
//
//  Created by Anton Cherkasov on 12.04.2025.
//

import Foundation

protocol ContentLocalizationProtocol {
	var newItemText: String { get }
	var newNoteText: String { get }
	var placeholderTitle: String { get }
	var placeholderDescription: String { get }
	var newItemDetailsTitle: String { get }
	var editItemDetailsTitle: String { get }
	var iconPickerNavigationTitle: String { get }
}

// MARK: - ContentLocalizationProtocol
final class ContentLocalization: ContentLocalizationProtocol {

	var newItemText: String {
		return String(localized: "new-item-text", table: "ContentLocalizable")
	}

	var newNoteText: String {
		return String(localized: "new-note-text", table: "ContentLocalizable")
	}

	var placeholderTitle: String {
		return String(localized: "placeholder-title", table: "ContentLocalizable")
	}

	var placeholderDescription: String {
		return String(localized: "placeholder-description", table: "ContentLocalizable")
	}

	var newItemDetailsTitle: String {
		return String(localized: "new-item-details-title", table: "ContentLocalizable")
	}

	var editItemDetailsTitle: String {
		return String(localized: "edit-item-details-title", table: "ContentLocalizable")
	}

	var iconPickerNavigationTitle: String {
		return String(localized: "icon-picker-navigation-title", table: "ContentLocalizable")
	}
}

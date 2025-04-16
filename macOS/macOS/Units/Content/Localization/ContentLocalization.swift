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
}

// MARK: - ContentLocalizationProtocol
final class ContentLocalization: ContentLocalizationProtocol {

	var newItemText: String {
		return String(localized: "new-item-text", table: "ContentLocalizable")
	}

	var newNoteText: String {
		return String(localized: "new-note-text", table: "ContentLocalizable")
	}
}

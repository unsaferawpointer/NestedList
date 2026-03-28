//
//  DocumentLocalization.swift
//  Nested List
//
//  Created by Anton Cherkasov on 25.08.2025.
//

import Foundation

protocol DocumentLocalizationProtocol {
	var newItemToolbarItemLabel: String { get }
	var viewToolbarItemLabel: String { get }
}

// MARK: - DocumentLocalizationProtocol
final class DocumentLocalization: DocumentLocalizationProtocol {

	var newItemToolbarItemLabel: String {
		return String(localized: "new-item-toolbar-item-label", table: "DocumentLocalizable")
	}

	var viewToolbarItemLabel: String {
		return String(localized: "view-toolbar-item-label", table: "DocumentLocalizable")
	}
}

//
//  DocumentLocalization.swift
//  Nested List
//
//  Created by Anton Cherkasov on 25.08.2025.
//

import Foundation

protocol DocumentLocalizationProtocol {
	var newItemToolbarItemLabel: String { get }
}

// MARK: - DocumentLocalizationProtocol
final class DocumentLocalization: DocumentLocalizationProtocol {

	var newItemToolbarItemLabel: String {
		return String(localized: "new-item-toolbar-item-label", table: "DocumentLocalizable")
	}
}

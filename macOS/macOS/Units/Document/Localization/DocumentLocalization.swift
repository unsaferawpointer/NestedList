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
	var unexpectedFormatErrorReason: String { get }
	var unknownVersionErrorReason: String { get }
}

// MARK: - DocumentLocalizationProtocol
final class DocumentLocalization: DocumentLocalizationProtocol {

	var newItemToolbarItemLabel: String {
		return String(localized: "new-item-toolbar-item-label", table: "DocumentLocalizable")
	}

	var viewToolbarItemLabel: String {
		return String(localized: "view-toolbar-item-label", table: "DocumentLocalizable")
	}

	var unexpectedFormatErrorReason: String {
		return String(localized: "document-error-unexpected-format-reason", table: "DocumentLocalizable")
	}

	var unknownVersionErrorReason: String {
		return String(localized: "document-error-unknown-version-reason", table: "DocumentLocalizable")
	}
}

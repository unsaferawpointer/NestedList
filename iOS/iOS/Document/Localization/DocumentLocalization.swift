//
//  DocumentLocalization.swift
//  iOS
//
//  Created by Anton Cherkasov on 18.04.2026.
//

import Foundation

protocol DocumentLocalizationProtocol {
	var defaulfDocumentName: String { get }
}

final class DocumentLocalization { }

// MARK: - DocumentLocalizationProtocol
extension DocumentLocalization: DocumentLocalizationProtocol {

	var defaulfDocumentName: String {
		String(localized: "defaulf-document-name", table: "DocumentLocalizable")
	}
}

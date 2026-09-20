//
//  DocumentLocalization.swift
//  iOS
//
//  Created by Anton Cherkasov on 18.04.2026.
//

import Foundation

protocol DocumentLocalizationProtocol {
	var defaulfDocumentName: String { get }
	var settingsItemTitle: String { get }
	var settingsViewControllerTitle: String { get }
}

final class DocumentLocalization { }

// MARK: - DocumentLocalizationProtocol
extension DocumentLocalization: DocumentLocalizationProtocol {

	var defaulfDocumentName: String {
		String(localized: "defaulf-document-name", table: "DocumentLocalizable")
	}

	var settingsItemTitle: String {
		String(localized: "settings-item-title", table: "DocumentLocalizable")
	}

	var settingsViewControllerTitle: String {
		String(localized: "settings-viewcontroller-title", table: "DocumentLocalizable")
	}
}

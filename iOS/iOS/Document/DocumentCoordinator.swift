//
//  DocumentCoordinator.swift
//  iOS
//
//  Created by Anton Cherkasov on 18.04.2026.
//

import UIKit
import os.log

final class DocumentCoordinator {

	// MARK: - DI by initialization

	private let localization: DocumentLocalizationProtocol

	// MARK: - Initialization

	init(localization: DocumentLocalizationProtocol = DocumentLocalization()) {
		self.localization = localization
	}
}

extension DocumentCoordinator {

	typealias ImportMode = UIDocumentBrowserViewController.ImportMode

	func documentBrowser(
		_ controller: UIDocumentBrowserViewController,
		didRequestDocumentCreationWithHandler importHandler: @escaping (URL?, ImportMode) -> Void
	) {
		os_log("Creating a new document.", log: .default, type: .debug)

		let url = FileManager.default.temporaryDirectory
			.appendingPathComponent(localization.defaulfDocumentName)
			.appendingPathExtension("nlist")


		let doc = Document(fileURL: url)
		doc.save(to: url, for: .forCreating) { saveSuccess in
			guard saveSuccess else {
				os_log("Unable to create a new document.", log: .default, type: .error)
				importHandler(nil, .none)
				return
			}

			doc.close { closeSuccess in
				guard closeSuccess else {
					os_log("Unable to create a new document.", log: .default, type: .error)
					importHandler(nil, .none)
					return
				}
				importHandler(url, .move)
			}
		}
	}
}

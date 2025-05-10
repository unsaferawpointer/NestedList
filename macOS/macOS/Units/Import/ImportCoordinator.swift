//
//  ImportCoordinator.swift
//  macOSUITests
//
//  Created by Anton Cherkasov on 10.05.2025.
//

import AppKit
import CoreModule

final class ImportCoordinator {

	func start() {
		let openPanel = NSOpenPanel()
		openPanel.allowedContentTypes = [.plainText]
		openPanel.allowsMultipleSelection = false
		openPanel.begin { [weak self] (result) in
			if result == .OK, let url = openPanel.url {
				self?.loadFile(at: url)
			}
		}
	}
}

// MARK: - Helpers
private extension ImportCoordinator {

	func loadFile(at url: URL) {
		do {

			let document = Document()
			try document.read(from: url, ofType: DocumentType.text.rawValue)
			document.updateChangeCount(.changeReadOtherContents)

			let displayName = url.deletingPathExtension().lastPathComponent

			document.fileURL = nil
			document.displayName = displayName

			NSDocumentController.shared.addDocument(document)
			document.makeWindowControllers()
			document.showWindows()

		} catch {
			NSApp.presentError(error)
		}
	}
}

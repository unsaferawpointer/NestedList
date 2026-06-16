//
//  DocumentController.swift
//  Nested List
//
//  Created by Anton Cherkasov on 07.05.2026.
//

import AppKit
import UniformTypeIdentifiers
import CoreModule

protocol DocumentControllerProtocol {
	func loadFile(at url: URL, with type: UTType)
}

final class DocumentController { }

// MARK: - DocumentControllerProtocol
extension DocumentController: DocumentControllerProtocol {

	func loadFile(at url: URL, with type: UTType) {
		do {
			let document = Document()
			try document.read(from: url, ofType: type.identifier)
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

//
//  ImportManager.swift
//  iOS
//
//  Created by Anton Cherkasov on 17.05.2025.
//

import UIKit
import UniformTypeIdentifiers
import CoreModule
import os.log

final class ImportManager {
	
}

extension ImportManager {

	static func shouldImport(file url: URL) -> Bool {
		return url.pathExtension == "txt"
	}

	static func importFile(from url: URL, completionHandler: @escaping (Document) -> Void) {

		let displayName = url.deletingPathExtension().lastPathComponent

		let newURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(displayName).nlist")

		let newDocument = Document(fileURL: newURL)
		url.startAccessingSecurityScopedResource()
		let data = try? Data(contentsOf: url)
		try? newDocument.load(fromContents: data, ofType: "public.plain-text")

		// Сохраняем и открываем
		newDocument.save(to: newURL, for: .forCreating) { success in
			if success {
				completionHandler(newDocument)
			}
		}
	}
}

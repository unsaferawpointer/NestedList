//
//  Document.swift
//  iOS
//
//  Created by Anton Cherkasov on 16.11.2024.
//

import UIKit
import CoreModule

class Document: UIDocument {

	// MARK: - DI

	lazy var storage: DocumentStorage<Content> = {
		return DocumentStorage<Content>(
			initialState: .empty,
			provider: DataProvider(),
			undoManager: undoManager
		)
	}()

	override func contents(forType typeName: String) throws -> Any {
		try storage.data(ofType: typeName)
	}

	override func load(fromContents contents: Any, ofType typeName: String?) throws {
		guard let data = contents as? Data, let typeName else {
			throw CocoaError(.coderReadCorrupt)
		}
		try storage.read(from: data, ofType: typeName)
	}
}


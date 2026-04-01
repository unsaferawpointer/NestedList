//
//  Document.swift
//  iOS
//
//  Created by Anton Cherkasov on 16.11.2024.
//

import UIKit
import CoreModule
import CorePresentation

class Document: UIDocument {

	weak var errorHandler: DocumentHandler?

	// MARK: - DI by property

	// MARK: - DI

	lazy var storage: DocumentStorage<Content> = {
		return DocumentStorage<Content>(
			stateProvider: StateProvider(initialState: .empty),
			contentProvider: DataProvider(),
			undoManager: undoManager
		)
	}()

	// MARK: - Document life-cycle

	override func contents(forType typeName: String) throws -> Any {
		try storage.data(ofType: typeName)
	}

	override func load(fromContents contents: Any, ofType typeName: String?) throws {
		guard let data = contents as? Data, let typeName else {
			throw CocoaError(.coderReadCorrupt)
		}

		guard Thread.current.isMainThread else {
			Task { @MainActor in
				try storage.read(from: data, ofType: typeName)
			}
			return
		}

		do {
			try storage.read(from: data, ofType: typeName)
		} catch let error as DocumentError {
			throw ErrorMapper.map(error: error)
		}
	}

	override func handleError(_ error: any Error, userInteractionPermitted: Bool) {
		super.handleError(error, userInteractionPermitted: userInteractionPermitted)

		if userInteractionPermitted {
			errorHandler?.handleError(error)
		}
	}
}

protocol DocumentHandler: AnyObject {
	func handleError(_ error: Error)
}

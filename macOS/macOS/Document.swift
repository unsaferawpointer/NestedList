//
//  Document.swift
//  macOS
//
//  Created by Anton Cherkasov on 16.11.2024.
//

import Cocoa
import CoreModule

class Document: NSDocument {

	// MARK: - DI

	lazy var storage: DocumentStorage<Content> = {
		return DocumentStorage<Content>(
			stateProvider: StateProvider<Content>(initialState: .empty),
			contentProvider: DataProvider(),
			undoManager: undoManager
		)
	}()

	override func printOperation(
		withSettings printSettings: [NSPrintInfo.AttributeKey : Any]
	) throws -> NSPrintOperation {
		guard
			let windowController = self.windowControllers.first,
			let view = windowController.contentViewController?.view
		else {
			throw NSError(domain: NSCocoaErrorDomain, code: NSUserCancelledError, userInfo: [NSLocalizedDescriptionKey: "No content to print"])
		}
		let printInfo = NSPrintInfo.shared
		for (key, value) in printSettings {
			printInfo.dictionary()[key] = value
		}

		return NSPrintOperation(view: view, printInfo: printInfo)
	}

	// MARK: - Override

	override class var autosavesInPlace: Bool {
		return true
	}

	override func makeWindowControllers() {
		// Returns the Storyboard that contains your Document window.
		let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
		let windowController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("Document Window Controller")) as! NSWindowController
		windowController.contentViewController = UnitAssembly.build(storage: storage)
		self.addWindowController(windowController)
	}

	override func data(ofType typeName: String) throws -> Data {
		try storage.data(ofType: typeName)
	}

	override func read(from data: Data, ofType typeName: String) throws {
		try storage.read(from: data, ofType: typeName)
	}

}

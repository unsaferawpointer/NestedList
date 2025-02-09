//
//  Document.swift
//  macOS
//
//  Created by Anton Cherkasov on 16.11.2024.
//

import Cocoa
import CoreModule

class Document: NSDocument {

	lazy var storage: DocumentStorage<Content> = {
		return DocumentStorage<Content>(
			stateProvider: StateProvider<Content>(initialState: .empty),
			contentProvider: DataProvider(),
			undoManager: undoManager
		)
	}()

	override init() {
	    super.init()
		// Add your subclass-specific initialization here.
	}

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

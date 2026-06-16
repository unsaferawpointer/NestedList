//
//  Document.swift
//  macOS
//
//  Created by Anton Cherkasov on 16.11.2024.
//

import Cocoa
import CoreModule
import CorePresentation

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
		let windowController = makeDocumentWindowController()
		addWindowController(windowController)
	}

	override func data(ofType typeName: String) throws -> Data {
		do {
			return try storage.data(ofType: typeName)
		} catch let error as DocumentError {
			throw ErrorMapper.map(error: error)
		}
	}

	override func read(from data: Data, ofType typeName: String) throws {
		do {
			try storage.read(from: data, ofType: typeName)
		} catch let error as DocumentError {
			throw ErrorMapper.map(error: error)
		}
	}

}

// MARK: - Private methods
private extension Document {

	func makeDocumentWindowController() -> NSWindowController {
		let contentViewController = DocumentAssembly.build(storage: storage)
		let window = NSWindow(
			contentRect: NSRect(x: 196, y: 240, width: 480, height: 270),
			styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
			backing: .buffered,
			defer: false
		)
		window.contentViewController = contentViewController
		window.isReleasedWhenClosed = false
		window.animationBehavior = .default

		let windowController = NSWindowController(window: window)
		windowController.windowFrameAutosaveName = "document-window"
		return windowController
	}
}

extension NSToolbarItem.Identifier {

	static let newItem = NSToolbarItem.Identifier("newItem")
}

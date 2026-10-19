//
//  Document.swift
//  macOS
//
//  Created by Anton Cherkasov on 16.11.2024.
//

import Cocoa
import CoreModule
import CorePresentation
import DesignSystem

class Document: NSDocument {

	private let windowFrameAutosaveName = "document-window-\(UUID().uuidString)"

	// MARK: - DI

	lazy var storage: DocumentStorage<DocumentContent> = {
		return DocumentStorage<DocumentContent>(
			stateProvider: StateProvider<DocumentContent>(initialState: .empty),
			contentProvider: DataProvider(),
			undoManager: undoManager
		)
	}()

	lazy var analytics: any ConcreteAnalyticsServiceProtocol<DocumentAnalyticsEvent> =
		ConcreteAnalyticsService<DocumentAnalyticsEvent>()

	lazy var toolbar: NSToolbar = {
		let view = NSToolbar()
		view.displayMode = .iconOnly
		view.delegate = self
		return view
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
			Task { await analytics.track(.read(type: typeName)) }
		} catch let error as DocumentError {
			Task { await analytics.track(.readError(error)) }
			throw ErrorMapper.map(error: error)
		}
	}
}

// MARK: - NSToolbarDelegate
extension Document: NSToolbarDelegate {

	func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
		[.space, .newItem]
	}

	func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
		[.space, .newItem]
	}

	func toolbar(
		_ toolbar: NSToolbar,
		itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier,
		willBeInsertedIntoToolbar flag: Bool
	) -> NSToolbarItem? {
		switch itemIdentifier {
		case .newItem:
			let item = NSMenuToolbarItem(itemIdentifier: itemIdentifier)
			item.label = String(localized: "new-item-toolbar-item-label", table: "ContentLocalizable")
			item.image = NSImage(systemSymbolName: "plus", accessibilityDescription: nil)!
			item.showsIndicator = true
			item.visibilityPriority = .high
			item.menu = MenuBuilder.build(
				for: [.newItem, .addMirror],
				target: nil,
				source: .toolbar
			)
			return item
		default:
			return nil
		}
	}
}

// MARK: - Private methods
private extension Document {

	func makeDocumentWindowController() -> NSWindowController {
		let contentViewController = DocumentAssembly.build(storage: storage)
		let window = NSWindow(
			contentRect: NSRect(x: 196, y: 240, width: 640, height: 480),
			styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
			backing: .buffered,
			defer: false
		)
		window.minSize = NSSize(width: 360, height: 240)
		window.contentViewController = contentViewController
		window.setContentSize(.init(width: 640, height: 480))
		window.toolbar = toolbar
		window.isReleasedWhenClosed = false
		window.animationBehavior = .default

		let windowController = NSWindowController(window: window)
		windowController.windowFrameAutosaveName = windowFrameAutosaveName
		return windowController
	}

}

// MARK: - Constants
extension NSToolbarItem.Identifier {

	static let newItem = NSToolbarItem.Identifier("newItem")
}

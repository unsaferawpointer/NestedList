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
		configureToolbar()
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

// MARK: - Actions
extension Document {

	@objc
	func changeView(_ sender: NSSegmentedControl) {
		guard
			let windowController = windowControllers.first,
			let window = windowController.window
		else {
			return
		}

		let view = DocumentContent.ContentView(rawValue: sender.indexOfSelectedItem) ?? .list
		guard view != storage.state.view else {
			return
		}

		Task { await analytics.track(.buttonClick(id: "document-view-\(view.analyticsIdentifier)")) }

		let size = window.frame.size
		storage.modificate { content in
			content.view = view
		}

		windowController.contentViewController = DocumentAssembly.build(storage: storage)
		configureToolbar()
		window.setContentSize(size)
	}
}

// MARK: - NSToolbarDelegate
extension Document: NSToolbarDelegate {

	func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
		return [.viewItem, .space, .newItem]
	}

	func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
		return [.viewItem, .space, .newItem]
	}

	func toolbar(
		_ toolbar: NSToolbar,
		itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier,
		willBeInsertedIntoToolbar flag: Bool
	) -> NSToolbarItem? {

		let item = NSToolbarItem(itemIdentifier: itemIdentifier)
		item.visibilityPriority = .high

		switch itemIdentifier {
		case .newItem:
			let image = NSImage(systemSymbolName: "plus", accessibilityDescription: nil)!
			let button = NSButton(image: image, target: nil, action: #selector(DocumentToolbarSupportable.newItem(_:)))
			button.bezelStyle = .toolbar
			button.imagePosition = .imageOnly
			button.sendAction(on: .leftMouseDown)

			item.label = newItemToolbarItemLabel
			item.view = button
		case .viewItem:
			let button = NSSegmentedControl(
				images: [
					NSImage(systemSymbolName: "list.bullet", accessibilityDescription: nil)!,
					NSImage(systemSymbolName: "rectangle.split.3x1", accessibilityDescription: nil)!
				],
				trackingMode: .selectOne,
				target: self,
				action: #selector(changeView(_:))
			)
			button.selectedSegment = storage.state.view.rawValue

			item.label = String(localized: "View")
			item.view = button
		default:
			break
		}

		return item
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
		window.minSize = NSSize(width: 360, height: 240)
		window.contentViewController = contentViewController
		window.toolbar = toolbar
		window.isReleasedWhenClosed = false
		window.animationBehavior = .default

		let windowController = NSWindowController(window: window)
		windowController.windowFrameAutosaveName = "document-window"
		return windowController
	}

	func configureToolbar() {
		let target = windowControllers.first?.contentViewController as? DocumentToolbarSupportable
		let newItem = toolbar.items.first { $0.itemIdentifier == .newItem }
		(newItem?.view as? NSButton)?.target = target
		newItem?.label = newItemToolbarItemLabel

		let viewItem = toolbar.items.first { $0.itemIdentifier == .viewItem }
		(viewItem?.view as? NSSegmentedControl)?.selectedSegment = storage.state.view.rawValue
	}

	var newItemToolbarItemLabel: String {
		switch storage.state.view {
		case .list:
			return String(localized: "new-item-toolbar-item-label", table: "ContentLocalizable")
		case .columns:
			return String(localized: "new-item-toolbar-item-label", table: "ColumnsLocalizable")
		}
	}
}

// MARK: - Constants
extension NSToolbarItem.Identifier {

	static let newItem = NSToolbarItem.Identifier("newItem")

	static let viewItem = NSToolbarItem.Identifier("viewItem")
}

// MARK: - Helpers
private extension DocumentContent.ContentView {

	var analyticsIdentifier: String {
		switch self {
		case .list:
			"list"
		case .columns:
			"columns"
		}
	}
}

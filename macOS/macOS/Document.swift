//
//  Document.swift
//  macOS
//
//  Created by Anton Cherkasov on 16.11.2024.
//

import Cocoa
import CoreModule

class Document: NSDocument {

	lazy var toolbar: NSToolbar = {
		let view = NSToolbar()
		view.delegate = self
		return view
	}()

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
		windowController.contentViewController = buildUnit(for: storage.state.view)

		windowController.window?.toolbar = toolbar
		windowController.window?.toolbar?.delegate = self
		self.addWindowController(windowController)
	}

	override func data(ofType typeName: String) throws -> Data {
		try storage.data(ofType: typeName)
	}

	override func read(from data: Data, ofType typeName: String) throws {
		try storage.read(from: data, ofType: typeName)
	}

}

// MARK: - Actions
extension Document {

	func buildUnit(for view: Content.ContentView) -> NSViewController {
		switch view {
		case .list:
			ContentUnitAssembly.build(
				storage: storage,
				configuration: .init(drawsBackground: true, hasInsets: true)
			)
		case .board:
			ColumnsUnitAssembly.build(
				storage: storage
			)
		}
	}

	@IBAction
	func changeView(_ sender: NSSegmentedControl) {

		guard
			let windowController = self.windowControllers.first,
			let size = windowController.window?.frame.size
		else {
			return
		}

		let view = Content.ContentView(rawValue: sender.indexOfSelectedItem) ?? .list

		guard view != storage.state.view else { return }
		storage.modificate { content in
			content.view = view
		}

		let viewController = buildUnit(for: view)
		windowController.contentViewController = viewController

		windowController.window?.setContentSize(size)
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
			let button = NSButton(image: image, target: nil, action:nil)

			item.label = "New Item"
			item.view = button
		case .viewItem:
			let button = NSSegmentedControl(
				images:
					[
						NSImage(systemSymbolName: "list.bullet", accessibilityDescription: nil)!,
						NSImage(systemSymbolName: "rectangle.split.3x1", accessibilityDescription: nil)!
					],
				trackingMode: .selectOne,
				target: nil,
				action: nil
			)
			button.action = #selector(changeView(_:))
			button.target = self
			button.selectedSegment = storage.state.view.rawValue

			item.label = "View"
			item.view = button
		default:
			break
		}

		return item
	}
}

extension NSToolbarItem.Identifier {

	static let newItem = NSToolbarItem.Identifier("newItem")

	static let viewItem = NSToolbarItem.Identifier("viewItem")
}

//
//  ContentViewController.swift
//  macOS
//
//  Created by Anton Cherkasov on 16.11.2024.
//

import Cocoa
import Hierarchy
import CoreModule
import DesignSystem
import CorePresentation

import SwiftUI

@MainActor protocol UnitViewOutput: ViewDelegate {
	func toolbarButtonClicked(id: ElementIdentifier)
	func menuItems() -> [ContentMenuIdentifier]
	func menuItemClicked(_ item: ContentMenuIdentifier, source: MenuSource)
	func validateMenuItem(_ item: ContentMenuIdentifier) -> Bool
	func stateForMenuItem(_ item: ContentMenuIdentifier) -> ControlState
}

@MainActor protocol UnitView: AnyObject, ListSupportable {
	func display(_ state: ContentViewState)
	func updateTitle(_ title: String)
	func close()
}

class ContentViewController: NSViewController {

	var adapter: ListAdapter<ItemModel>?

	// MARK: - DI

	var output: UnitViewOutput?

	// MARK: - Delegates

	weak var listDelegate: (any DesignSystem.ListDelegate<UUID>)?
	weak var dropDelegate: (any DesignSystem.DropDelegate<UUID>)?
	weak var dragDelegate: (any DesignSystem.DragDelegate<UUID>)?
	weak var cellDelegate: (any DesignSystem.CellDelegate<ItemModel>)?

	// MARK: - UI-Properties

	private var placeholderView: NSView?

	private let scrollview: NSScrollView = .standart

	private let table: NSOutlineView = .standart

	// MARK: - Toolbar

	private let localization: ContentLocalizationProtocol = ContentLocalization()

	lazy var toolbar: NSToolbar = {
		let view = NSToolbar()
		view.displayMode = .iconOnly
		view.delegate = self
		return view
	}()

	// MARK: - Initialization

	init(configure: (ContentViewController) -> Void) {
		super.init(nibName: nil, bundle: nil)
		configure(self)

		self.adapter = ListAdapter<ItemModel>(tableView: table)
		self.adapter?.dropDelegate = dropDelegate
		self.adapter?.cellDelegate = cellDelegate
		self.adapter?.dragDelegate = dragDelegate
		self.adapter?.delegate = listDelegate

		if let items = output?.menuItems() {
			self.adapter?.menu = MenuBuilder.build(for: items, target: self, source: .context)
		}
	}

	@available(*, unavailable, message: "Use init(storage:)")
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - View life-cycle

	override func loadView() {
		self.view = NSView()
		configureUserInterface()
		configureConstraints()
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		output?.viewDidChange(state: .didLoad)
	}

	override func viewWillAppear() {
		super.viewWillAppear()
		output?.viewDidChange(state: .willAppear)
		table.sizeLastColumnToFit()
	}

	override func viewDidAppear() {
		super.viewDidAppear()
		configureToolbarIfNeeded()
	}

}

// MARK: - ContentView
extension ContentViewController: UnitView {

	func display(_ state: ContentViewState) {
		placeholderView?.removeFromSuperview()
		switch state {
		case let .placeholder(model):
			placeholderView = NSHostingView(rootView: PlaceholderView(model: model))

			placeholderView?.setAccessibilityIdentifier("document-placeholder")
			placeholderView?.setAccessibilityRole(.group)

			placeholderView?.pin(edges: .all, to: view)
			adapter?.apply(.init())
		case let .list(snapshot):
			adapter?.apply(snapshot)
		}
	}

	func updateTitle(_ title: String) {
		self.title = title
	}

	func close() {
		if view.window?.contentViewController === self {
			view.window?.close()
		}
	}
}

// MARK: - ListSupportable
extension ContentViewController: ListSupportable {

	var selection: [UUID] {
		adapter?.effectiveSelection ?? []
	}

	func scroll(to id: UUID) {
		adapter?.scroll(to: id)
	}

	func select(_ id: UUID) {
		adapter?.select(id)
	}

	func focus(on id: UUID, key: String) {
		adapter?.focus(on: id, with: key)
	}

	func expand(_ ids: [UUID]?) {
		adapter?.expand(ids)
	}
}

// MARK: - Helpers
private extension ContentViewController {

	func configureUserInterface() {

		table.frame = scrollview.bounds
		table.headerView = nil
		scrollview.additionalSafeAreaInsets = .horizontal(16)
		scrollview.drawsBackground = true

		let column = NSTableColumn(identifier: .init("main"))
		table.addTableColumn(column)

		scrollview.documentView = table
		scrollview.drawsBackground = false
	}

	func configureToolbarIfNeeded() {
		guard let window = view.window, window.toolbar == nil else {
			return
		}
		window.toolbar = toolbar
	}

	func configureConstraints() {
		scrollview.translatesAutoresizingMaskIntoConstraints = false

		if !view.subviews.contains(where: { $0 == scrollview }) {
			view.addSubview(scrollview)
		}

		NSLayoutConstraint.activate(
			[
				scrollview.topAnchor.constraint(equalTo: view.topAnchor),
				scrollview.leadingAnchor.constraint(equalTo: view.leadingAnchor),
				scrollview.trailingAnchor.constraint(equalTo: view.trailingAnchor),
				scrollview.bottomAnchor.constraint(equalTo: view.bottomAnchor)
			]
		)
	}
}

// MARK: - DocumentToolbarSupportable
extension ContentViewController: DocumentToolbarSupportable {

	func newItem(_ sender: Any) {
		output?.toolbarButtonClicked(id: .init(rawValue: "new-item-toolbar-item"))
	}
}

// MARK: - NSToolbarDelegate
extension ContentViewController: NSToolbarDelegate {

	func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
		return [.space, .newItem]
	}

	func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
		return [.space, .newItem]
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
			let button = NSButton(image: image, target: self, action: #selector(DocumentToolbarSupportable.newItem(_:)))
			button.bezelStyle = .toolbar
			button.imagePosition = .imageOnly
			button.sendAction(on: .leftMouseDown)

			item.label = localization.newItemToolbarItemLabel
			item.view = button
		default:
			break
		}

		return item
	}
}

// MARK: - Interaction Delegate
extension ContentViewController {

	@objc
	func menuItemClicked(_ sender: NSMenuItem) {
		guard
			let rawValue = sender.identifier?.rawValue,
			let id = ContentMenuIdentifier(rawValue: rawValue),
			let sourceRawValue = sender.representedObject as? String,
			let source = MenuSource(rawValue: sourceRawValue)
		else {
			return
		}
		output?.menuItemClicked(id, source: source)
	}

	@IBAction
	func cut(_ sender: NSMenuItem) {
		output?.menuItemClicked(.cutItems, source: .main)
	}

	@IBAction
	func copy(_ sender: NSMenuItem) {
		output?.menuItemClicked(.copyItems, source: .main)
	}

	@IBAction
	func paste(_ sender: NSMenuItem) {
		output?.menuItemClicked(.paste, source: .main)
	}
}

// MARK: - NSMenuItemValidation
extension ContentViewController: NSMenuItemValidation {

	func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {

		guard
			let rawValue = menuItem.identifier?.rawValue,
			let id = ContentMenuIdentifier(rawValue: rawValue),
			let output
		else {
			return false
		}

		menuItem.state = output.stateForMenuItem(id).value
		return output.validateMenuItem(id)
	}
}

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

import SwiftUI

protocol UnitViewOutput: ViewDelegate, MenuDelegate { }

protocol UnitView: AnyObject, ListSupportable {
	func display(_ snapshot: Snapshot<ItemModel>)
}

class ContentViewController: NSViewController {

	var adapter: ListAdapter<ItemModel>?

	var output: UnitViewOutput?

	weak var listDelegate: (any DesignSystem.ListDelegate<UUID>)?
	weak var dropDelegate: (any DesignSystem.DropDelegate<UUID>)?
	weak var dragDelegate: (any DesignSystem.DragDelegate<UUID>)?
	weak var cellDelegate: (any DesignSystem.CellDelegate<ItemModel>)?

	// MARK: - UI-Properties

	lazy var placeholderView: NSView = {
		let view = NSHostingView(
			rootView: PlaceholderView.init(
				title: "No items yet",
				subtitle: "To add a new item, click the «plus» button or use the keyboard shortcut ⌘T"
			)
		)
		return view
	}()

	lazy var scrollview: NSScrollView = {
		let view = NSScrollView()
		view.borderType = .noBorder
		view.hasHorizontalScroller = false
		view.autohidesScrollers = true
		view.hasVerticalScroller = false
		view.automaticallyAdjustsContentInsets = true
		return view
	}()

	lazy var table: NSOutlineView = {
		let view = NSOutlineView()
		view.style = .inset
		view.rowSizeStyle = .custom
		view.floatsGroupRows = false
		view.allowsMultipleSelection = true
		view.allowsColumnResizing = false
		view.usesAlternatingRowBackgroundColors = false
		view.autoresizesOutlineColumn = false
		view.usesAutomaticRowHeights = false
		view.indentationPerLevel = 24
		view.backgroundColor = .clear
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
		self.adapter?.menu = MenuBuilder.build()
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
}

// MARK: - UnitView
extension ContentViewController: UnitView {

	func display(_ snapshot: Snapshot<ItemModel>) {
		adapter?.apply(snapshot)
		placeholderView.isHidden = !snapshot.root.isEmpty
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
		scrollview.additionalSafeAreaInsets = .horizontal(32)

		let column = NSTableColumn(identifier: .init("main"))
		table.addTableColumn(column)

		scrollview.documentView = table
	}

	func configureConstraints() {
		scrollview.pin(edges: .all, to: view)
		placeholderView.pin(edges: .all, to: view)
	}
}

// MARK: - Interaction Delegate
extension ContentViewController {

	@objc
	func menuItemClicked(_ sender: NSMenuItem) {
		guard let rawValue = sender.identifier?.rawValue else {
			return
		}
		let id = ElementIdentifier(rawValue: rawValue)
		output?.menuItemClicked(id)
	}

	@IBAction
	func newItem(_ sender: NSMenuItem) {
		output?.menuItemClicked(.newItem)
	}
}

// MARK: - NSMenuItemValidation
extension ContentViewController: NSMenuItemValidation {

	func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {

		guard let rawValue = menuItem.identifier?.rawValue, let output else {
			return false
		}

		let id = ElementIdentifier(rawValue: rawValue)

		menuItem.state = output.stateForMenuItem(id).value
		return output.validateMenuItem(id)
	}
}

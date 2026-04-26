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

@MainActor
protocol UnitViewOutput: ViewDelegate, MenuDelegate {
	func configure(for root: UUID?)
}

@MainActor
protocol UnitView: AnyObject, ListSupportable {
	func display(_ state: ContentViewState)
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
			self.adapter?.menu = MenuBuilder.build(for: items, target: self)
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

	var sheet: NSViewController?
}

extension ContentViewController {

	func configure(for root: UUID?) {
		output?.configure(for: root)
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
	}

	func configureConstraints() {
		scrollview.pin(edges: .all, to: view)
	}
}

// MARK: - DocumentToolbarSupportable
extension ContentViewController: DocumentToolbarSupportable {

	func newItem(_ sender: Any) {
		output?.menuItemClicked(.newItem)
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
	func cut(_ sender: NSMenuItem) {
		output?.menuItemClicked(.cut)
	}

	@IBAction
	func copy(_ sender: NSMenuItem) {
		output?.menuItemClicked(.copy)
	}

	@IBAction
	func paste(_ sender: NSMenuItem) {
		output?.menuItemClicked(.paste)
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

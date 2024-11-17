//
//  ViewController.swift
//  macOS
//
//  Created by Anton Cherkasov on 16.11.2024.
//

import Cocoa
import Hierarchy
import DesignSystem

protocol UnitViewOutput {
	func viewDidLoad()

	func userCreateNewItem()
	func userDeleteItem()
}

protocol UnitView: AnyObject, ListSupportable {
	func display(_ snapshot: Snapshot<ItemModel>)
}

class ViewController: NSViewController {

	var adapter: ListAdapter<ItemModel>?

	var output: UnitViewOutput?
	weak var dropDelegate: (any DesignSystem.DropDelegate<UUID>)?

	// MARK: - UI-Properties

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
		view.rowSizeStyle = .default
		view.floatsGroupRows = false
		view.allowsMultipleSelection = true
		view.allowsColumnResizing = false
		view.usesAlternatingRowBackgroundColors = false
		view.usesAutomaticRowHeights = false
		view.indentationPerLevel = 24
		return view
	}()

	// MARK: - Initialization

	init(configure: (ViewController) -> Void) {
		super.init(nibName: nil, bundle: nil)
		configure(self)
		self.adapter = ListAdapter<ItemModel>(tableView: table)
		self.adapter?.dropDelegate = dropDelegate
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
		output?.viewDidLoad()
	}

	override func viewWillAppear() {
		super.viewWillAppear()
		table.sizeLastColumnToFit()
	}
}

// MARK: - UnitView
extension ViewController: UnitView {

	func display(_ snapshot: Snapshot<ItemModel>) {
		adapter?.apply(snapshot)
	}
}

// MARK: - ListSupportable
extension ViewController: ListSupportable {

	var selection: [UUID] {
		adapter?.effectiveSelection ?? []
	}

	func scroll(to id: UUID) {
		adapter?.scroll(to: id)
	}

	func select(_ id: UUID) {
		adapter?.select(id)
	}

	func focus(on id: UUID) {
		adapter?.focus(on: id)
	}

	func expand(_ ids: [UUID]?) {
		adapter?.expand(ids)
	}
}

// MARK: - Helpers
private extension ViewController {

	func configureUserInterface() {

		table.frame = scrollview.bounds
		table.headerView = nil
		view.additionalSafeAreaInsets = .horizontal(32)

		let column = NSTableColumn(identifier: .init("main"))
		table.addTableColumn(column)

		scrollview.documentView = table

		table.menu = MenuBuilder.build()
	}

	func configureConstraints() {
		[scrollview].forEach {
			view.addSubview($0)
			$0.translatesAutoresizingMaskIntoConstraints = false
		}

		NSLayoutConstraint.activate(
			[
				scrollview.leadingAnchor.constraint(equalTo: view.leadingAnchor),
				scrollview.trailingAnchor.constraint(equalTo: view.trailingAnchor),
				scrollview.topAnchor.constraint(equalTo: view.topAnchor),
				scrollview.bottomAnchor.constraint(equalTo: view.bottomAnchor)
			]
		)
	}
}

// MARK: - MenuSupportable
extension ViewController: MenuSupportable {

	func newItem(_ sender: NSMenuItem) {
		output?.userCreateNewItem()
	}
	
	func deleteItem(_ sender: NSMenuItem) {
		output?.userDeleteItem()
	}
}

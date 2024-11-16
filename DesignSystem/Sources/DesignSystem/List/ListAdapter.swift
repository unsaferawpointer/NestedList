//
//  ListAdapter.swift
//  DesignSystem
//
//  Created by Anton Cherkasov on 16.11.2024.
//

import Hierarchy

#if canImport(Cocoa)
import Cocoa
#endif

#if os(macOS)
public final class ListAdapter<Model: CellModel>: NSObject, NSOutlineViewDataSource, NSOutlineViewDelegate {

	typealias ID = Model.ID

	weak var tableView: NSOutlineView?

	// MARK: - Data

	private var snapshot = Snapshot<Model>()

	private var cache: [ID: Item] = [:]

	// MARK: - Initialization

	public init(tableView: NSOutlineView) {
		self.tableView = tableView
		super.init()

		tableView.dataSource = self
		tableView.delegate = self
	}

	// MARK: - NSOutlineViewDataSource

	public func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
		guard
			let item = item as? Item
		else {
			let id = snapshot.rootItem(at: index).id
			return cache[unsafe: id]
		}
		let id = snapshot.childOfItem(item.id, at: index).id
		return cache[unsafe: id]
	}

	public func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
		guard
			let item = item as? Item
		else {
			return snapshot.numberOfRootItems()
		}
		return snapshot.numberOfChildren(ofItem: item.id)
	}

	public func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
		guard let item = item as? Item else {
			return false
		}
		return snapshot.numberOfChildren(ofItem: item.id) > 0
	}

	// MARK: - NSOutlineViewDelegate

	public func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {

		let isHeader = tableColumn == nil

		guard let item = item as? Item, !isHeader else {
			return nil
		}

		let model = snapshot.model(with: item.id)
		return makeCellIfNeeded(for: model, in: outlineView)
	}
}

// MARK: - Public interface
public extension ListAdapter {

	@MainActor
	func apply(_ snapshot: Snapshot<Model>) {

		let old = self.snapshot

		self.snapshot = snapshot

		let deleted = old.identifiers.subtracting(snapshot.identifiers)
		let inserted = snapshot.identifiers.subtracting(old.identifiers)

		for id in deleted {
			cache[id] = nil
		}
		for id in inserted {
			cache[id] = Item(id: id)
		}

		tableView?.reloadData()
	}
}

extension ListAdapter {

	@MainActor
	func makeCellIfNeeded<T: CellModel>(for model: T, in table: NSTableView) -> NSView? {

		typealias Cell = T.Cell

		let id = NSUserInterfaceItemIdentifier(Cell.reuseIdentifier)
		var view = table.makeView(withIdentifier: id, owner: self) as? Cell
		if view == nil {
			view = Cell(model)
			view?.identifier = id
			return view
		}
		view?.model = model
		view?.action = model.action
		return view
	}
}

// MARK: - Nested data structs
private extension ListAdapter {

	final class Item {

		var id: ID

		init(id: ID) {
			self.id = id
		}
	}
}
#endif

//
//  ListAdapter.swift
//  DesignSystem
//
//  Created by Anton Cherkasov on 16.11.2024.
//

import Hierarchy

#if canImport(Cocoa)
import Cocoa
#elseif canImport(UIKit)
import UIKit
#endif

#if os(macOS)
public final class ListAdapter<Model: CellModel>: NSObject,
												  NSOutlineViewDataSource,
												  NSOutlineViewDelegate where Model.ID: Codable {

	public typealias ID = Model.ID

	weak var tableView: NSOutlineView?

	private var animator = ListAnimator<Model>()

	// MARK: - Delegates

	public weak var dropDelegate: (any DropDelegate<ID>)?

	public weak var dragDelegate: (any DragDelegate<ID>)?

	public weak var cellDelegate: (any CellDelegate<Model>)?

	// MARK: - Data

	private var snapshot = Snapshot<Model>()

	private var cache: [ID: Item] = [:]

	// MARK: - UI-State

	private(set) var selection = Set<ID>()

	public var effectiveSelection: [ID] {
		guard let tableView else {
			return []
		}
		return tableView.effectiveSelection().compactMap {
			tableView.item(atRow: $0) as? Item
		}
		.map(\.id)
	}

	// MARK: - Initialization

	public init(tableView: NSOutlineView) {
		self.tableView = tableView
		super.init()

		tableView.dataSource = self
		tableView.delegate = self

		tableView.registerForDraggedTypes([.identifier, .string])
		tableView.setDraggingSourceOperationMask(.copy, forLocal: false)
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

	// MARK: - Drag And Drop support

	public func outlineView(_ outlineView: NSOutlineView, pasteboardWriterForItem item: Any) -> NSPasteboardWriting? {
		guard let item = item as? Item else {
			return nil
		}

		let pasteboardItem = NSPasteboardItem()

		let encoder = JSONEncoder()
		guard let data = try? encoder.encode(item.id) else {
			return nil
		}

		pasteboardItem.setData(data, forType: .identifier)

		return pasteboardItem
	}

	public func outlineView(
		_ outlineView: NSOutlineView,
		draggingSession session: NSDraggingSession,
		willBeginAt screenPoint: NSPoint,
		forItems draggedItems: [Any]
	) {

		let ids = draggedItems.compactMap { item in
			item as? Item
		}.map { item in
			return item.id
		}

		precondition(session.draggingPasteboard.pasteboardItems?.count == ids.count)

		let pasteboard = Pasteboard(pasteboard: session.draggingPasteboard)
		dragDelegate?.write(ids: ids, to: pasteboard)
	}

	public func outlineView(
		_ outlineView: NSOutlineView,
		validateDrop info: NSDraggingInfo,
		proposedItem item: Any?,
		proposedChildIndex index: Int
	) -> NSDragOperation {

		let destination = getDestination(proposedItem: item, proposedChildIndex: index)
		let ids = getIdentifiers(from: info)

		guard let dropDelegate else {
			return []
		}

		if isLocal(from: info) {
			guard info.draggingSourceOperationMask == .copy else {
				let isValid = dropDelegate.validateMovement(ids, to: destination)
				return isValid ? .private : []
			}
			return .copy
		}

		guard let info = Pasteboard(pasteboard: info.draggingPasteboard).getInfo() else {
			return []
		}

		return dropDelegate.validateDrop(info, to: destination) ? .copy : []
	}

	public func outlineView(_ outlineView: NSOutlineView, acceptDrop info: NSDraggingInfo, item: Any?, childIndex index: Int) -> Bool {

		guard let dropDelegate else {
			return false
		}

		let destination = getDestination(proposedItem: item, proposedChildIndex: index)

		guard !isLocal(from: info) else {
			let ids = getIdentifiers(from: info)
			if info.draggingSourceOperationMask == .copy {
				dropDelegate.copy(ids, to: destination)
			} else {
				dropDelegate.move(ids, to: destination)
			}
			if let id = destination.id, let targetItem = cache[id] {
				tableView?.expandItem(targetItem, expandChildren: false)
			}
			return true
		}

		guard let info = Pasteboard(pasteboard: info.draggingPasteboard).getInfo() else {
			return false
		}

		dropDelegate.drop(info, to: destination)

		return false
	}

	// MARK: - Selection support

	public func outlineView(
		_ outlineView: NSOutlineView,
		selectionIndexesForProposedSelection proposedSelectionIndexes: IndexSet
	) -> IndexSet {
		selection.removeAll()
		for index in proposedSelectionIndexes {
			guard let item = tableView?.item(atRow: index) as? Item else {
				continue
			}
			selection.insert(item.id)
		}
		return proposedSelectionIndexes
	}

	public func outlineViewItemDidExpand(_ notification: Notification) {
		validateSelection()
	}
}

// MARK: - Support selection
private extension ListAdapter {

	func validateSelection() {
		let rows = selection.compactMap { id -> Int? in
			guard let item = cache[id], let row = tableView?.row(forItem: item), row != -1 else {
				return nil
			}
			return row
		}
		tableView?.selectRowIndexes(.init(rows), byExtendingSelection: false)
	}
}

// MARK: - Public interface
public extension ListAdapter {

	func apply(_ new: Snapshot<Model>) {

		let old = snapshot

		let intersection = old.identifiers.intersection(new.identifiers)

		for id in intersection {
			let item = cache[unsafe: id]
			let model = new.model(with: id)
			guard let row = tableView?.row(forItem: item), row != -1 else {
				continue
			}
			configureRow(with: model, at: row)
		}

		tableView?.beginUpdates()
		let (deleted, inserted) = animator.calculate(old: snapshot, new: new)
		for id in deleted {
			cache[id] = nil
			selection.remove(id)
		}
		for id in inserted {
			cache[id] = Item(id: id)
		}

		self.snapshot = new
		animator.calculate(old: old, new: new) { [weak self] animation in
			guard let self else {
				return
			}
			switch animation {
			case .remove(let offset, let parent):
				let item = cache[optional: parent]
				let rows = IndexSet(integer: offset)
				tableView?.removeItems(
					at: rows,
					inParent: item,
					withAnimation: [.effectFade, .effectGap]
				)
			case .insert(let offset, let parent):
				let destination = cache[optional: parent]
				let rows = IndexSet(integer: offset)
				tableView?.insertItems(
					at: rows,
					inParent: destination,
					withAnimation: [.effectFade, .effectGap]
				)
			case .reload(let id):
				guard let item = cache[optional: id] else {
					return
				}
				tableView?.reloadItem(item)
			}
		}
		tableView?.endUpdates()
		validateSelection()
	}

	func scroll(to id: ID) {
		guard let tableView, let item = cache[id] else {
			return
		}
		let row = tableView.row(forItem: item)
		guard row >= 0 else {
			return
		}

		NSAnimationContext.runAnimationGroup { context in
			context.allowsImplicitAnimation = true
			tableView.scrollRowToVisible(row)
		}
	}

	func select(_ id: ID) {
		guard let tableView, let item = cache[id] else {
			return
		}
		let row = tableView.row(forItem: item)
		guard row >= 0 else {
			return
		}

		tableView.selectRowIndexes(.init(integer: row), byExtendingSelection: false)
	}

	func expand(_ ids: [ID]?) {

		guard let ids else {
			tableView?.animator().expandItem(nil, expandChildren: true)
			return
		}

		NSAnimationContext.runAnimationGroup { context in
			let items = ids.compactMap { cache[$0] }
			for item in items {
				tableView?.animator().expandItem(item)
			}
		}
	}

	func focus(on id: ID) {
		guard let item = cache[id], let row = tableView?.row(forItem: item), row != -1 else {
			return
		}
		let view = tableView?.view(atColumn: 0, row: row, makeIfNecessary: false)
		_ = view?.becomeFirstResponder()
	}
}

extension ListAdapter {

	func getDestination(proposedItem item: Any?, proposedChildIndex index: Int) -> Destination<ID> {
		switch (item, index) {
		case (.none, -1):
			return .toRoot
		case (.none, let index):
			return .inRoot(atIndex: index)
		case (let item as Item, -1):
			return .onItem(with: item.id)
		case (let item as Item, let index):
			return .inItem(with: item.id, atIndex: index)
		default:
			fatalError()
		}
	}

	func isLocal(from info: NSDraggingInfo) -> Bool {

		guard let source = info.draggingSource as? NSOutlineView else {
			return false
		}

		return source === tableView
	}

	func getIdentifiers(from info: NSDraggingInfo) -> [ID] {

		guard let pasteboardItems = info.draggingPasteboard.pasteboardItems else {
			return []
		}

		let decoder = JSONDecoder()

		return pasteboardItems.compactMap { item in
			item.data(forType: .identifier)
		}.compactMap { data in
			return try? decoder.decode(ID.self, from: data)
		}
	}
}

extension ListAdapter {

	func makeCellIfNeeded(for model: Model, in table: NSTableView) -> NSView? {

		typealias Cell = Model.Cell

		let id = NSUserInterfaceItemIdentifier(Cell.reuseIdentifier)
		var view = table.makeView(withIdentifier: id, owner: self) as? Cell
		if view == nil {
			view = Cell(model)
			view?.identifier = id
			view?.delegate = cellDelegate
			return view
		}
		view?.model = model
		view?.delegate = cellDelegate
		return view
	}

	func configureRow<T: CellModel>(with model: T, at row: Int) {

		typealias Cell = T.Cell

		guard let tableView else {
			return
		}

		let cell = tableView.view(atColumn: 0, row: row, makeIfNecessary: false) as? Cell
		cell?.model = model

	}
}

private extension NSPasteboard.PasteboardType {

	static let identifier: Self = .init("dev.zeroindex.ListAdapter.identifier")
}

// MARK: - Nested data structs
private extension ListAdapter {

	final class Item: Identifiable {

		var id: ID

		init(id: ID) {
			self.id = id
		}
	}
}
#endif

#if os(iOS)
public final class ListAdapter<Model: CellModel>: NSObject, UITableViewDataSource {

	public typealias ID = Model.ID

	weak var list: UITableView?

	// MARK: - Data

	private var snapshot = Snapshot<Model>()

	// MARK: - Cache

	private(set) var expanded: Set<ID> = []

	// MARK: - Initialization

	public init(list: UITableView) {
		self.list = list
		super.init()

		list.dataSource = self
		list.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
	}

	// MARK: - UITableViewDataSource

	public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		let models = snapshot.flattened { item in
			expanded.contains(item.id)
		}
		return models.count
	}

	public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

		return cell
	}
}
#endif

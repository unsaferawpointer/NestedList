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
												  NSMenuDelegate,
												  NSOutlineViewDelegate where Model.ID: Codable {

	public typealias ID = Model.ID

	typealias InternalModel = ListModel<Model>

	weak var tableView: NSOutlineView?

	private var animator = ListAnimator<InternalModel>()

	// MARK: - Public Properties

	public weak var menu: NSMenu? {
		didSet {
			tableView?.menu = menu
			tableView?.menu?.delegate = self
		}
	}

	// MARK: - Delegates

	public weak var delegate: (any ListDelegate<ID>)?

	public weak var dropDelegate: (any DropDelegate<ID>)?

	public weak var dragDelegate: (any DragDelegate<ID>)?

	public weak var cellDelegate: (any CellDelegate<Model>)?

	// MARK: - Data

	private var snapshot = Snapshot<InternalModel>()

	private var cache: [InternalModel.ID: Item] = [:]

	// MARK: - UI-State

	private(set) var selection = Set<ID>()

	public var effectiveSelection: [ID] {
		guard let tableView else {
			return []
		}
		return tableView.effectiveSelection().compactMap {
			tableView.item(atRow: $0) as? Item
		}.compactMap { item in
			switch item.id {
			case .item(let id):
				return id
			case .spacer:
				return nil
			}
		}
	}

	// MARK: - Initialization

	public init(tableView: NSOutlineView) {
		self.tableView = tableView
		super.init()

		tableView.dataSource = self
		tableView.delegate = self

		DragManager.registerTypes(in: tableView)

		tableView.target = self
		tableView.doubleAction = #selector(handleDoubleClick(_:))
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
		let id = internalId(for: item)
		return snapshot.numberOfChildren(ofItem: id) > 0
	}

	// MARK: - NSOutlineViewDelegate

	public func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
		guard case let .model(value) = internalModel(for: item) else {
			return nil
		}
		return CellFactory.makeCellIfNeeded(for: value, in: tableView, delegate: cellDelegate)
	}

	public func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat {
		switch internalModel(for: item) {
		case .model(let value):
			return value.height ?? NSView.noIntrinsicMetric
		case .spacer(_, let height):
			return height.rawValue
		}
	}

	// MARK: - Drag And Drop support

	public func outlineView(_ outlineView: NSOutlineView, pasteboardWriterForItem item: Any) -> NSPasteboardWriting? {
		guard let id = identifier(for: item) else {
			return nil
		}
		return DragManager.write(id, to: NSPasteboardItem())
	}

	public func outlineView(
		_ outlineView: NSOutlineView,
		draggingSession session: NSDraggingSession,
		willBeginAt screenPoint: NSPoint,
		forItems draggedItems: [Any]
	) {

		let ids = draggedItems.compactMap { item in
			item as? Item
		}.compactMap { item in
			switch item.id {
			case .item(let id):
				return id
			case .spacer:
				return nil
			}
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

		let ids: [ID] = DragManager.identifiers(from: info)

		guard let dropDelegate, let destination = getDestination(proposedItem: item, proposedChildIndex: index) else {
			return []
		}

		if DragManager.isLocal(from: info, in: outlineView) {
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

		guard let dropDelegate, let destination = getDestination(proposedItem: item, proposedChildIndex: index) else {
			return false
		}

		guard !DragManager.isLocal(from: info, in: outlineView) else {
			let ids: [ID] = DragManager.identifiers(from: info)
			if info.draggingSourceOperationMask == .copy {
				dropDelegate.copy(ids, to: destination)
			} else {
				dropDelegate.move(ids, to: destination)
			}
			if let id = destination.id, let targetItem = cache[.item(id: id)] {
				tableView?.expandItem(targetItem, expandChildren: false)
			}
			return true
		}

		guard let info = Pasteboard(pasteboard: info.draggingPasteboard).getInfo() else {
			return false
		}

		dropDelegate.drop(info, to: destination)

		return true
	}

	// MARK: - Selection support

	public func outlineView(
		_ outlineView: NSOutlineView,
		selectionIndexesForProposedSelection proposedSelectionIndexes: IndexSet
	) -> IndexSet {
		selection.removeAll()

		var result = IndexSet()
		for index in proposedSelectionIndexes {
			guard let item = tableView?.item(atRow: index) as? Item, case let .item(id) = item.id else {
				continue
			}
			selection.insert(id)
			result.insert(index)
		}
		return result
	}

	public func outlineViewItemDidExpand(_ notification: Notification) {
		validateSelection()
	}

	@objc
	func handleDoubleClick(_ sender: Any?) {
		let clickedRow = tableView?.clickedRow ?? -1
		guard clickedRow != -1, let item = tableView?.item(atRow: clickedRow) as? Item, case let .item(id) = item.id else {
			return
		}

		delegate?.handleDoubleClick(on: id)
	}

	// MARK: - Menu Support

	public func menuNeedsUpdate(_ menu: NSMenu) {
		let clickedRow = tableView?.clickedRow ?? -1
		guard clickedRow != -1, let item = tableView?.item(atRow: clickedRow) as? Item else {
			return
		}

		let model = snapshot.model(with: item.id)
		guard !model.isDecoration else {
			menu.cancelTracking()
			return
		}
	}
}

// MARK: - Support selection
private extension ListAdapter {

	func validateSelection() {
		let rows = selection.compactMap { id -> Int? in
			guard let item = cache[.item(id: id)], let row = tableView?.row(forItem: item), row != -1 else {
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

		let nodes = new.getNodes()

		let transformed = nodes.map {
			$0.map { model in
				ListModel<Model>.model(model)
			}
		}

		let first = transformed.first?.id

		let converted = Snapshot(transformed).insert { model, level -> ListModel<Model>? in
			guard model.isGroup, case let .model(value) = model, model.id != first else {
				return nil
			}
			return .spacer(before: value.id, height: level == 0 ? .large : .small)
		}

		apply(converted)
	}

	func scroll(to id: ID) {
		guard let item = cache[.item(id: id)] else {
			return
		}
		tableView?.scroll(to: item)
	}

	func select(_ id: ID) {
		guard let item = cache[.item(id: id)] else {
			return
		}
		tableView?.select(item)
	}

	func expand(_ ids: [ID]?) {
		let items = ids?.compactMap {
			cache[.item(id: $0)]
		}
		tableView?.expand(items)
	}

	func focus(on id: ID, with key: String) {
		guard let item = cache[.item(id: id)], let row = tableView?.row(forItem: item), row != -1 else {
			return
		}
		let cell = tableView?.view(atColumn: 0, row: row, makeIfNecessary: false) as? Model.Cell
		cell?.focus(on: key)
	}
}

// MARK: - Helpers
private extension ListAdapter {

	func internalModel(for item: Any) -> InternalModel {
		guard let item = item as? Item else {
			fatalError("Invalid item type")
		}
		return snapshot.model(with: item.id)
	}

	func internalId(for item: Any) -> InternalModel.ID {
		guard let item = item as? Item else {
			fatalError("Invalid item type")
		}
		return item.id
	}

	func identifier(for item: Any) -> ID? {
		guard
			let item = item as? Item,
			case let .item(id) = item.id
		else {
			return nil
		}
		return id
	}

	func apply(_ new: Snapshot<InternalModel>) {

		let old = snapshot

		let intersection = old.identifiers.intersection(new.identifiers)

		// MARK: - Update height

		var updateHeight = IndexSet()
		for id in intersection {

			let oldModel = old.model(with: id)
			let newModel = new.model(with: id)

			let oldIndex = old.globalIndex(for: id)

			guard oldModel.height != newModel.height else {
				continue
			}
			updateHeight.insert(oldIndex)
		}

		// MARK: - Update content

		for id in intersection {

			let item = cache[unsafe: id]

			let oldModel = old.model(with: id)
			let newModel = new.model(with: id)

			guard !oldModel.contentIsEquals(to: newModel) else {
				continue
			}

			guard let row = tableView?.row(forItem: item), row != -1 else {
				continue
			}
			switch newModel {
			case .model(let value):
				CellFactory.configureCell(with: value, at: row, in: tableView)
			case .spacer:
				continue
			}
		}

		let (deleted, inserted) = animator.calculate(old: snapshot, new: new)
		for id in deleted {
			cache[id] = nil
			if case let .item(id) = id {
				selection.remove(id)
			}
		}
		for id in inserted {
			cache[id] = Item(id: id)
		}

		self.snapshot = new
		tableView?.noteHeightOfRows(withIndexesChanged: updateHeight)

		// MARK: - Animate

		tableView?.beginUpdates()
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

	func getDestination(proposedItem item: Any?, proposedChildIndex index: Int) -> Destination<ID>? {
		switch (item, index) {
		case (.none, -1):
			return .toRoot
		case (.none, let index):

			let numberOfRootItems = snapshot.numberOfRootItems()
			if index < numberOfRootItems {
				let model = snapshot.rootItem(at: index)
				guard case .model = model else {
					return nil
				}
			}

			let shift = snapshot.contains(in: nil, maxIndex: index) { $0.isDecoration }
			return .inRoot(atIndex: index - shift)
		case (let item as Item, -1):
			guard case .item(let id) = item.id else {
				return nil
			}
			return .onItem(with: id)
		case (let item as Item, let index):
			guard case .item(let id) = item.id else {
				return nil
			}

			let numberOfItems = snapshot.numberOfChildren(ofItem: item.id)
			if index < numberOfItems {
				let model = snapshot.childOfItem(item.id, at: index)
				guard case .model = model else {
					return nil
				}
			}

			let shift = snapshot.contains(in: item.id, maxIndex: index) { $0.isDecoration }

			return .inItem(with: id, atIndex: index - shift)
		default:
			fatalError()
		}
	}
}

// MARK: - Nested data structs
private extension ListAdapter {

	final class Item: Identifiable {

		var id: InternalModel.ID

		init(id: InternalModel.ID) {
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

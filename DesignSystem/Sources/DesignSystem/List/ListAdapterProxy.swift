//
//  ListAdapterProxy.swift
//  DesignSystem
//
//  Created by Anton Cherkasov on 19.05.2025.
//

import Hierarchy

#if canImport(Cocoa)
import Cocoa
#endif

#if os(macOS)
public final class ListAdapterProxy<Model: CellModel> where Model.ID: Codable {

	public typealias ID = Model.ID

	typealias InternalModel = ListModel<Model>

	weak var tableView: NSOutlineView?

	private var animator = ListAnimator<InternalModel>()

	// MARK: - Public Properties

	public weak var menu: NSMenu? {
		didSet {
			tableView?.menu = menu
		}
	}

	// MARK: - Managers

	lazy var dropManager: DropManager<ID> = {
		return DropManager(list: tableView!)
	}()

	// MARK: - Delegates

	public weak var delegate: (any ListDelegate<ID>)?

	public weak var dropDelegate: (any DropDelegate<ID>)? {
		get {
			dropManager.delegate
		}
		set {
			dropManager.delegate = newValue
		}
	}

	public weak var dragDelegate: (any DragDelegate<ID>)?

	public weak var cellDelegate: (any CellDelegate<Model>)?

	// MARK: - Data

	private var snapshot = Snapshot<InternalModel>()

	private var cache: [InternalModel.ID: Item] = [:]

	// MARK: - UI-State

	private(set) var selection = Set<ID>()

	public var effectiveSelection: [ID] {
		guard let selection = tableView?.effectiveSelection() else {
			return []
		}
		return selection.compactMap {
			guard let item = tableView?.item(atRow: $0) as? Item, case let .item(id) = item.id else {
				return nil
			}
			return id
		}
	}

	// MARK: - Initialization

	public init(tableView: NSOutlineView) {
		self.tableView = tableView
	}
}

// MARK: - NSOutlineViewDataSource
extension ListAdapterProxy {

	func child(at index: Int, ofItem parent: InternalModel.ID?) -> Any {
		guard let parent else {
			let id = snapshot.rootItem(at: index).id
			return cache[unsafe: id]
		}
		let id = snapshot.childOfItem(parent, at: index).id
		return cache[unsafe: id]
	}

	func numberOfChildrenOfItem(_ parent: InternalModel.ID?) -> Int {
		guard let parent else {
			return snapshot.numberOfRootItems()
		}
		return snapshot.numberOfChildren(ofItem: parent)
	}

	func isItemExpandable(item: InternalModel.ID) -> Bool {
		return snapshot.numberOfChildren(ofItem: item) > 0
	}
}

// MARK: - NSOutlineViewDelegate
extension ListAdapterProxy {

	func view(forItem id: InternalModel.ID, in tableView: NSOutlineView) -> NSView? {
		guard case let .model(value) = snapshot.model(with: id) else {
			return nil
		}
		return CellFactory.makeCellIfNeeded(for: value, in: tableView, delegate: cellDelegate)
	}

	func heightOfRow(byItem id: InternalModel.ID) -> CGFloat {
		switch snapshot.model(with: id) {
		case .model(let value):
			return value.height ?? NSView.noIntrinsicMetric
		case .spacer(_, let height):
			return height.rawValue
		}
	}
}

// MARK: - Drag And Drop support
extension ListAdapterProxy {

	func pasteboardWriter(for item: InternalModel.ID) -> NSPasteboardWriting? {
		guard case let .item(id) = item else {
			return nil
		}
		return DragManager.write(id, to: NSPasteboardItem())
	}

	func draggingWillBegin(
		draggingSession session: NSDraggingSession,
		willBeginAt screenPoint: NSPoint,
		forItems draggedItems: [InternalModel.ID]
	) {

		let ids = draggedItems.compactMap { id in
			switch id {
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

	func validateDrop(
		_ outlineView: NSOutlineView,
		info: NSDraggingInfo,
		to rawDestination: Destination<InternalModel.ID>
	) -> NSDragOperation {
		guard let destination = normalize(destination: rawDestination) else {
			return []
		}
		return dropManager.validateDrop(info: info, to: destination)
	}

	func acceptDrop(_ outlineView: NSOutlineView, info: NSDraggingInfo, to rawDestination: Destination<InternalModel.ID>) -> Bool {

		guard let destination = normalize(destination: rawDestination) else {
			return false
		}

		let result = dropManager.acceptDrop(info: info, to: destination)

		if let id = destination.id, let targetItem = cache[.item(id: id)] {
			tableView?.expandItem(targetItem, expandChildren: false)
		}

		outlineView.window?.makeKeyAndOrderFront(nil)

		return result
	}
}

// MARK: - Selection support
extension ListAdapterProxy {

	func selectionIndexes(for proposedSelectionIndexes: IndexSet) -> IndexSet {
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

	func outlineViewItemDidExpand(_ notification: Notification) {
		validateSelection()
	}

	func handleDoubleClick(basicId: InternalModel.ID) {
		guard case let .item(id) = basicId else {
			return
		}

		delegate?.handleDoubleClick(on: id)
	}
}

// MARK: - Menu Support
extension ListAdapterProxy {

	func menuNeedsUpdate(_ menu: NSMenu) {
		guard let item = tableView?.clickedItem(with: Item.self) else {
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
private extension ListAdapterProxy {

	func validateSelection() {
		let rows = selection.compactMap { id -> Int? in
			guard let item = cache[.item(id: id)], let row = tableView?.row(forItem: item) else {
				return nil
			}
			return row != -1 ? row : nil
		}
		tableView?.selectRowIndexes(.init(rows), byExtendingSelection: false)
	}
}

// MARK: - Public interface
public extension ListAdapterProxy {

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
private extension ListAdapterProxy {

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

	func normalize(destination: Destination<InternalModel.ID>) -> Destination<ID>? {
		switch destination {
		case .toRoot:
			return .toRoot
		case let .inRoot(index):

			let numberOfRootItems = snapshot.numberOfRootItems()
			if index < numberOfRootItems {
				let model = snapshot.rootItem(at: index)
				guard case .model = model else {
					return nil
				}
			}

			let shift = snapshot.contains(in: nil, maxIndex: index) { $0.isDecoration }
			return .inRoot(atIndex: index - shift)
		case let .onItem(basicId):
			guard case .item(let id) = basicId else {
				return nil
			}
			return .onItem(with: id)
		case let .inItem(basicId, index):
			guard case .item(let id) = basicId else {
				return nil
			}

			let numberOfItems = snapshot.numberOfChildren(ofItem: basicId)
			if index < numberOfItems {
				let model = snapshot.childOfItem(basicId, at: index)
				guard case .model = model else {
					return nil
				}
			}

			let shift = snapshot.contains(in: basicId, maxIndex: index) {
				$0.isDecoration
			}

			return .inItem(with: id, atIndex: index - shift)
		}
	}
}

// MARK: - Nested data structs
extension ListAdapterProxy {

	final class Item: Identifiable {

		var id: InternalModel.ID

		init(id: InternalModel.ID) {
			self.id = id
		}
	}
}
#endif

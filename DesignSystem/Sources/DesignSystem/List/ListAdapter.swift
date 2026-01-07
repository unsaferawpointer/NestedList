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
@MainActor
public final class ListAdapter<Model: CellModel>: NSObject,
												  NSOutlineViewDataSource,
												  NSMenuDelegate,
												  NSOutlineViewDelegate where Model.ID: Codable {

	public typealias ID = Model.ID

	typealias InternalModel = ListModel<Model>

	// MARK: - Public Properties

	public weak var menu: NSMenu? {
		didSet {
			proxy.menu = menu
			proxy.menu?.delegate = self
		}
	}

	unowned var tableView: NSOutlineView

	// MARK: - Delegates

	public weak var delegate: (any ListDelegate<ID>)? {
		didSet {
			proxy.delegate = delegate
		}
	}

	public weak var dropDelegate: (any DropDelegate<ID>)? {
		didSet {
			proxy.dropDelegate = dropDelegate
		}
	}

	public weak var dragDelegate: (any DragDelegate<ID>)? {
		didSet {
			proxy.dragDelegate = dragDelegate
		}
	}

	public weak var cellDelegate: (any CellDelegate<Model>)? {
		didSet {
			proxy.cellDelegate = cellDelegate
		}
	}

	// MARK: - UI-State

	public var effectiveSelection: [ID] {
		return proxy.effectiveSelection
	}

	// MARK: - Proxy

	private var proxy: ListAdapterProxy<Model>

	// MARK: - Initialization

	public init(tableView: NSOutlineView) {
		self.proxy = .init(tableView: tableView)
		self.tableView = tableView
		super.init()

		tableView.dataSource = self
		tableView.delegate = self

		tableView.target = self
		tableView.doubleAction = #selector(handleDoubleClick(_:))
	}

	// MARK: - NSOutlineViewDataSource

	public func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
		return proxy.child(at: index, ofItem: identifier(of: item))
	}

	public func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
		return proxy.numberOfChildrenOfItem(identifier(of: item))
	}

	public func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
		return proxy.isItemExpandable(item: identifier(of: item))
	}

	// MARK: - NSOutlineViewDelegate

	public func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
		return proxy.view(forItem: identifier(of: item), in: outlineView)
	}

	public func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat {
		return proxy.heightOfRow(byItem: identifier(of: item))
	}

	// MARK: - Drag And Drop support

	public func outlineView(_ outlineView: NSOutlineView, pasteboardWriterForItem item: Any) -> NSPasteboardWriting? {
		return proxy.pasteboardWriter(for: identifier(of: item))
	}

	public func outlineView(
		_ outlineView: NSOutlineView,
		draggingSession session: NSDraggingSession,
		willBeginAt screenPoint: NSPoint,
		forItems draggedItems: [Any]
	) {

		let ids = draggedItems.compactMap { item in
			identifier(of: item)
		}

		proxy.draggingWillBegin(
			draggingSession: session,
			willBeginAt: screenPoint,
			forItems: ids
		)
	}

	public func outlineView(
		_ outlineView: NSOutlineView,
		validateDrop info: NSDraggingInfo,
		proposedItem item: Any?,
		proposedChildIndex index: Int
	) -> NSDragOperation {
		let destination = getDestination(proposedItem: item, proposedChildIndex: index)
		return proxy.validateDrop(outlineView, info: info, to: destination)
	}

	public func outlineView(_ outlineView: NSOutlineView, acceptDrop info: NSDraggingInfo, item: Any?, childIndex index: Int) -> Bool {
		let destination = getDestination(proposedItem: item, proposedChildIndex: index)
		return proxy.acceptDrop(outlineView, info: info, to: destination)
	}

	// MARK: - Selection support

	public func outlineView(
		_ outlineView: NSOutlineView,
		selectionIndexesForProposedSelection proposedSelectionIndexes: IndexSet
	) -> IndexSet {
		proxy.selectionIndexes(for: proposedSelectionIndexes)
	}

	public func outlineViewItemDidExpand(_ notification: Notification) {
		proxy.outlineViewItemDidExpand(notification)
	}

	@objc
	func handleDoubleClick(_ sender: Any?) {
		guard let item = tableView.clickedItem(with: ListAdapterProxy<Model>.Item.self) else {
			return
		}
		proxy.handleDoubleClick(basicId: item.id)
	}

	// MARK: - Menu Support

	public func menuNeedsUpdate(_ menu: NSMenu) {
		proxy.menuNeedsUpdate(menu)
	}
}

// MARK: - Helpers
private extension ListAdapter {

	func identifier(of item: Any?) -> InternalModel.ID? {
		return (item as? ListAdapterProxy<Model>.Item)?.id
	}

	func identifier(of item: Any) -> InternalModel.ID {
		guard let item = item as? ListAdapterProxy<Model>.Item else {
			fatalError("Invalid item type")
		}
		return item.id
	}

	func getDestination(proposedItem item: Any?, proposedChildIndex index: Int) -> Destination<InternalModel.ID> {
		return switch (item, index) {
		case (.none, -1):
			.toRoot
		case (.none, let index):
			.inRoot(atIndex: index)
		case (let item as ListAdapterProxy<Model>.Item, -1):
			.onItem(with: item.id)
		case (let item as ListAdapterProxy<Model>.Item, let index):
			.inItem(with: item.id, atIndex: index)
		default:
			fatalError()
		}
	}
}

// MARK: - Public interface
public extension ListAdapter {

	func apply(_ new: Snapshot<Model>) {
		proxy.apply(new)
	}

	func scroll(to id: ID) {
		proxy.scroll(to: id)
	}

	func select(_ id: ID) {
		proxy.select(id)
	}

	func expand(_ ids: [ID]?) {
		proxy.expand(ids)
	}

	func focus(on id: ID, with key: String) {
		proxy.focus(on: id, with: key)
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

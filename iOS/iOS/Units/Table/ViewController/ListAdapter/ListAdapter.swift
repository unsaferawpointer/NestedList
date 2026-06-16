//
//  ListAdapter.swift
//  iOS
//
//  Created by Anton Cherkasov on 25.05.2025.
//

import UIKit
import DesignSystem
import Hierarchy

@MainActor
final class ListAdapter: NSObject {

	weak var tableView: UITableView?

	var delegate: (any ContentViewDelegate<UUID>)? {
		get {
			manager.delegate
		}
		set {
			manager.delegate = newValue
		}
	}

	var editingMode: EditingMode? {
		get {
			manager.editingMode
		}
		set {
			manager.editingMode = newValue
		}
	}

	var selection: [UUID] {
		get {
			manager.selection
		}
	}

	// MARK: - Manager

	private(set) var manager: ListManager<ItemModel>

	// MARK: - Initialization

	init(tableView: UITableView?, delegate: (any ContentViewDelegate<UUID>)?) {
		self.tableView = tableView
		self.manager = ListManager(tableView: tableView!, delegate: delegate)
		super.init()

		self.tableView?.dataSource = self
		self.tableView?.delegate = self
		self.tableView?.dragDelegate = self
		self.tableView?.dropDelegate = self
	}
}

extension ListAdapter {

	func apply(newSnapshot: Snapshot<ItemModel>) {
		manager.apply(newSnapshot: newSnapshot)
	}

	func scroll(to id: UUID) {
		manager.scroll(to: id)
	}

	func expand(_ id: UUID) {
		manager.expand(id)
	}

	func expandAll() {
		manager.expandAll()
	}

	func collapseAll() {
		manager.collapseAll()
	}

	func selectAll() {
		manager.selectAll()
	}

	var isEmpty: Bool {
		manager.isEmpty
	}
}

// MARK: - UITableViewDataSource
extension ListAdapter: UITableViewDataSource {

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return manager.numberOfRows()
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		return manager.cellForRow(at: indexPath)
	}
}

// MARK: - UITableViewDelegate
extension ListAdapter: UITableViewDelegate {

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		manager.didSelect(at: indexPath)
	}

	func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
		manager.didDeselectRow(at: indexPath)
	}

	func tableView(
		_ tableView: UITableView,
		contextMenuConfigurationForRowAt indexPath: IndexPath,
		point: CGPoint
	) -> UIContextMenuConfiguration? {
		manager.contextMenuConfigurationForRow(at: indexPath)
	}

	func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
		manager.editingStyleForRow(at: indexPath)
	}

	func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
		manager.commitEditingStyle(editingStyle: editingStyle, forRowAt: indexPath)
	}

	func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
		manager.shouldIndentWhileEditingRow(at: indexPath)
	}
}

// MARK: - UITableViewDragDelegate
extension ListAdapter: UITableViewDragDelegate {

	func tableView(
		_ tableView: UITableView,
		itemsForBeginning session: any UIDragSession,
		at indexPath: IndexPath
	) -> [UIDragItem] {
		manager.itemsForBeginning(session: session, at: indexPath)
	}

}

// MARK: - UITableViewDropDelegate
extension ListAdapter: UITableViewDropDelegate {

	func tableView(_ tableView: UITableView, canHandle session: any UIDropSession) -> Bool {
		manager.tableView(tableView, canHandle: session)
	}

	func tableView(_ tableView: UITableView, dragSessionWillBegin session: any UIDragSession) {
		manager.tableView(tableView, dragSessionWillBegin: session)
	}

	func tableView(
		_ tableView: UITableView,
		dropSessionDidUpdate session: any UIDropSession,
		withDestinationIndexPath destinationIndexPath: IndexPath?
	) -> UITableViewDropProposal {
		manager.tableView(tableView, dropSessionDidUpdate: session, withDestinationIndexPath: destinationIndexPath)
	}

	func tableView(_ tableView: UITableView, dragSessionDidEnd session: any UIDragSession) {
		manager.tableView(tableView, dragSessionDidEnd: session)
	}

	func tableView(_ tableView: UITableView, performDropWith coordinator: any UITableViewDropCoordinator) {
		manager.tableView(tableView, performDropWith: coordinator)
	}
}

// MARK: - Moving support
extension ListAdapter {

	func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
		manager.tableView(tableView, canMoveRowAt: indexPath)
	}

	func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) { }

}

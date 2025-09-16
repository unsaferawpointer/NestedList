//
//  NestedList.swift
//  iOS
//
//  Created by Anton Cherkasov on 16.09.2025.
//

import UIKit
import Hierarchy

final class NestedList: UIView {

	// MARK: - Data

	var adapter: ListAdapter?

	// MARK: - UI-Properties

	lazy var tableView: UITableView = {
		let tableView = UITableView(frame: .zero, style: .plain)
		tableView.separatorStyle = .none
		tableView.showsVerticalScrollIndicator = false

		tableView.allowsMultipleSelection = false

		tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
		return tableView
	}()
}

// MARK: - Public Interface
extension NestedList {

	var isEmpty: Bool {
		return adapter?.isEmpty ?? true
	}

	func setDelegate(_ delegate: (any ContentViewDelegate<UUID>)?) {
		self.adapter = ListAdapter(tableView: tableView, delegate: delegate)
	}

	func setEditing(_ editingMode: EditingMode?) {
		self.adapter?.editingMode = editingMode
	}

	var selection: [UUID] {
		return adapter?.selection ?? []
	}

	func display(_ snapshot: Snapshot<ItemModel>) {
		performUpdate { [weak self] in
			self?.adapter?.apply(newSnapshot: snapshot)
		}
	}

	func expand(_ id: UUID) {
		adapter?.expand(id)
	}

	func scroll(to id: UUID) {
		adapter?.scroll(to: id)
	}

	func expandAll() {
		adapter?.expandAll()
	}

	func collapseAll() {
		adapter?.collapseAll()
	}

}

// MARK: - Helpers
private extension NestedList {

	func performUpdate(_ block: @escaping () -> Void) {
		if Thread.isMainThread {
			block()
		} else {
			DispatchQueue.main.async {
				block()
			}
		}
	}

	func configureLayout() {
		tableView.pin(edges: .all, to: self)
	}
}

//
//  ListDataSource.swift
//  iOS
//
//  Created by Anton Cherkasov on 07.01.2025.
//

import Foundation
import Hierarchy

final class ListStorage {

	weak var delegate: CacheDelegate?

	// MARK: - State

	private var expanded: Set<UUID> = []

	private var list: [UUID] = []

	// MARK: - Snapshots

	private var snapshot = Snapshot<ItemModel>()

	private var backup: Snapshot<ItemModel>?
}

extension ListStorage {

	func destination(for row: Int) -> Destination<UUID> {
		guard row < list.count else {
			return .toRoot
		}
		let id = list[row]
		return snapshot.destination(ofItem: id)
	}

	var isEmpty: Bool {
		return list.isEmpty
	}
}

// MARK: - Moving support
extension ListStorage {

	func beginMovement(for id: ItemModel.ID) {
		// Save current state
		self.backup = snapshot

		let modificated = modificate { root in
			root.deleteItem(id)
		}
		apply(newSnapshot: modificated)
	}

	@discardableResult
	func endMovement(for id: ItemModel.ID, to destination: Destination<ItemModel.ID>) -> Destination<ItemModel.ID> {
		defer {
			self.backup = nil
		}
		guard let backup else {
			fatalError("Incosistent state")
		}
		// Same location
		if
			backup.parent(for: id)?.id == destination.id,
			let rawIndex = destination.index,
			backup.localIndex(for: id) < rawIndex + 1
		{
			let shiftedDestination = destination.shifted(by: 1)

			let modificated = modificate { root in
				let node = Node(value: backup.model(with: id))
				root.insertItems(from: [node], to: destination)
			}

			apply(newSnapshot: modificated)

			return shiftedDestination
		}

		let modificated = modificate { root in
			let node = Node(value: backup.model(with: id))
			root.insertItems(from: [node], to: destination)
		}
		apply(newSnapshot: modificated)

		return destination
	}

	func cancelMovement() {
		guard let backup else {
			return
		}
		self.snapshot = backup
		apply(newSnapshot: backup)
		self.backup = nil
	}
}

// MARK: - Helpers
private extension ListStorage {

	func modificate(_ block: (Root<ItemModel>) -> Void) -> Snapshot<ItemModel> {
		let nodes = snapshot.getNodes()
		let root = Root<ItemModel>(hierarchy: nodes)
		block(root)
		return Snapshot(root.nodes)
	}
}

// MARK: - Public interface
extension ListStorage {

	var count: Int {
		return list.count
	}

	func row(for id: UUID) -> Int? {
		return list.firstIndex(of: id)
	}

	func apply(newSnapshot: Snapshot<ItemModel>) {
		apply(newSnapshot: newSnapshot, newExpanded: expanded)
	}

	func rowConfiguration(for index: Int) -> RowConfiguration {
		let id = list[index]
		return RowConfiguration(
			level: snapshot.level(for: id),
			isExpanded: expanded.contains(id),
			isLeaf: snapshot.isLeaf(id: id)
		)
	}

	func identifier(for row: Int) -> UUID {
		return list[row]
	}

	func model(with index: Int) -> ItemModel {
		let id = list[index]
		return snapshot.model(with: id)
	}

	func toggle(indexPath: IndexPath) {
		let index = indexPath.row
		let id = list[index]

		if expanded.contains(id) {
			collapse(id)
		} else {
			expand(id)
		}
	}

	func collapse(_ id: UUID) {
		expanded.remove(id)

		guard let index = list.firstIndex(of: id) else {
			assertionFailure("Invalid index of id = \(id)")
			return
		}

		let rowConfiguration = RowConfiguration(
			level: snapshot.level(for: id),
			isExpanded: false,
			isLeaf: snapshot.isLeaf(id: id)
		)

		delegate?.updateCell(indexPath: .init(row: index, section: 0), rowConfiguration: rowConfiguration)

		let oldList = list
		let newList = snapshot.flattened { item in
			self.expanded.contains(item.id)
		}.map(\.id)
		self.list = newList
		animate(oldList: oldList, newList: newList)
	}

	func expandAll() {
		apply(newSnapshot: snapshot, newExpanded: snapshot.nodeIdentifiers)
	}

	func collapseAll() {
		expanded.removeAll()
		apply(newSnapshot: snapshot)
	}

	func expand(_ id: UUID) {
		expanded.insert(id)
		guard let index = list.firstIndex(of: id) else {
			assertionFailure("Invalid index of id = \(id)")
			return
		}

		let rowConfiguration = RowConfiguration(
			level: snapshot.level(for: id),
			isExpanded: true,
			isLeaf: snapshot.isLeaf(id: id)
		)

		delegate?.updateCell(indexPath: .init(row: index, section: 0), rowConfiguration: rowConfiguration)

		let oldList = list
		let newList = snapshot.flattened { item in
			self.expanded.contains(item.id)
		}.map(\.id)
		self.list = newList
		animate(oldList: oldList, newList: newList)
	}
}

// MARK: - Helpers
private extension ListStorage {

	func apply(newSnapshot: Snapshot<ItemModel>, newExpanded: Set<UUID>) {

		let oldList = list
		let oldSnapshot = snapshot

		let newList = newSnapshot.flattened { item in
			newExpanded.contains(item.id)
		}.map(\.id)

		let updated = Set(oldList).intersection(newList)

		for id in updated {

			let oldIndex = oldList.firstIndex(where: { $0 == id })!

			let oldModel = oldSnapshot.model(with: id)
			let newModel = newSnapshot.model(with: id)

			let oldConfiguration = RowConfiguration(
				level: oldSnapshot.level(for: id),
				isExpanded: expanded.contains(id),
				isLeaf: oldSnapshot.isLeaf(id: id)
			)

			let newConfiguration = RowConfiguration(
				level: newSnapshot.level(for: id),
				isExpanded: newExpanded.contains(id),
				isLeaf: newSnapshot.isLeaf(id: id)
			)

			if oldModel != newModel {
				delegate?.updateCell(indexPath: .init(row: oldIndex, section: 0), model: newModel)
			}

			if oldConfiguration != newConfiguration {
				delegate?.updateCell(indexPath: .init(row: oldIndex, section: 0), rowConfiguration: newConfiguration)
			}
		}

		self.snapshot = newSnapshot
		self.expanded = newExpanded
		self.list = newList

		animate(oldList: oldList, newList: newList)

	}

	func animate(oldList: [UUID], newList: [UUID]) {

		let diff = newList.difference(from: oldList)

		delegate?.beginUpdates()

		var toRemove = [IndexPath]()
		var toInsert = [IndexPath]()
		for change in diff {
			switch change {
			case let .remove(offset, _, _):
				let indexPath = IndexPath(row: offset, section: 0)
				toRemove.append(indexPath)
			case let .insert(offset, _, _):
				let indexPath = IndexPath(row: offset, section: 0)
				toInsert.append(indexPath)
			}
		}

		delegate?.update(deleteRows: toRemove, insertRows: toInsert)
		delegate?.endUpdates()
	}
}

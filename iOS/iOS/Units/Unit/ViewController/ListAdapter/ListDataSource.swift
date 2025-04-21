//
//  ListDataSource.swift
//  iOS
//
//  Created by Anton Cherkasov on 07.01.2025.
//

import Foundation
import Hierarchy

final class ListDataSource {

	var expanded: Set<UUID> = []

	var snapshot = Snapshot<ItemModel>()

	var list: [UUID] = []

	weak var delegate: CacheDelegate?
}

extension ListDataSource {

	func destination(for row: Int) -> Destination<UUID> {
		guard row < list.count else {
			return .toRoot
		}
		let id = list[row]
		return snapshot.destination(ofItem: id)
	}
}

// MARK: - Public interface
extension ListDataSource {

	var count: Int {
		return list.count
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
private extension ListDataSource {

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

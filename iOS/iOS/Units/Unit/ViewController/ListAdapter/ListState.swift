//
//  ListState.swift
//  iOS
//
//  Created by Anton Cherkasov on 11.05.2025.
//

import Foundation
import Hierarchy

struct ListState {

	var expanded: Set<UUID> = []

	var snapshot: Snapshot<ItemModel> = .init()
}

// MARK: - Computed Properties
extension ListState {

	var count: Int {
		return flattened.count
	}

	var isEmpty: Bool {
		return flattened.isEmpty
	}

	func destination(for row: Int) -> Destination<UUID> {
		guard row < flattened.count else {
			return .toRoot
		}
		let id = flattened[row]
		return snapshot.destination(ofItem: id)
	}

	var flattened: [UUID] {
		return snapshot.flattened { item in
			expanded.contains(item.id)
		}.map {
			$0.id
		}
	}

	func row(for id: UUID) -> Int? {
		return flattened.firstIndex(of: id)
	}

	func identifier(for row: Int) -> UUID {
		return flattened[row]
	}

	func model(for row: Int) -> ItemModel {
		let id = flattened[row]
		return snapshot.model(with: id)
	}

	func model(for id: UUID) -> ItemModel {
		return snapshot.model(with: id)
	}

	func configuration(for row: Int) -> RowConfiguration {
		let id = flattened[row]
		return configuration(for: id)
	}

	func configuration(for id: UUID) -> RowConfiguration {
		return RowConfiguration(
			level: snapshot.level(for: id),
			isExpanded: expanded.contains(id),
			isLeaf: snapshot.isLeaf(id: id)
		)
	}

	func expanded(id: UUID) -> ListState {
		let newExpanded = expanded.union([id])
		return ListState(
			expanded: newExpanded,
			snapshot: snapshot
		)
	}

	func collapsed(id: UUID) -> ListState {
		let newExpanded = expanded.subtracting([id])
		return ListState(
			expanded: newExpanded,
			snapshot: snapshot
		)
	}

	func allExpanded() -> ListState {
		return ListState(
			expanded: Set(snapshot.identifiers),
			snapshot: snapshot
		)
	}

	func allCollapsed() -> ListState {
		return ListState(
			expanded: .init(),
			snapshot: snapshot
		)
	}

	func toggled(id: UUID) -> ListState {
		return expanded.contains(id) ? collapsed(id: id) : expanded(id: id)
	}

	func replaced(with snapshot: Snapshot<ItemModel>) -> ListState {

		let newExpanded = expanded.intersection(snapshot.identifiers)

		return ListState(
			expanded: newExpanded,
			snapshot: snapshot
		)
	}

	func deleted(id: UUID) -> ListState {
		let nodes = snapshot.getNodes()
		let root = Root<ItemModel>(hierarchy: nodes)
		root.deleteItem(id)
		let newExpanded = expanded.subtracting([id])
		return ListState(
			expanded: newExpanded,
			snapshot: Snapshot(root.nodes)
		)
	}

	func inserted(model: ItemModel, to destination: Destination<UUID>) -> ListState {
		let root = Root<ItemModel>(hierarchy: snapshot.getNodes())
		root.insertItems(with: [model], to: destination)

		return ListState(
			expanded: expanded,
			snapshot: Snapshot(root.nodes)
		)
	}
}

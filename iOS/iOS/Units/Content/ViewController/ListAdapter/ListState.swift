//
//  ListState.swift
//  iOS
//
//  Created by Anton Cherkasov on 11.05.2025.
//

import Foundation
import Hierarchy
import DesignSystem

struct ListState<Model: CellModel> {

	var expanded: Set<Model.ID> = []

	var snapshot: Snapshot<Model> = .init()
}

// MARK: - Computed Properties
extension ListState {

	var count: Int {
		return flattened.count
	}

	var isEmpty: Bool {
		return flattened.isEmpty
	}

	func destination(for row: Int) -> Destination<Model.ID> {
		guard row < flattened.count else {
			return .toRoot
		}
		let id = flattened[row]
		return snapshot.destination(ofItem: id)
	}

	var flattened: [Model.ID] {
		return snapshot.flattened { item in
			expanded.contains(item.id)
		}.map {
			$0.id
		}
	}

	func row(for id: Model.ID) -> Int? {
		return flattened.firstIndex(of: id)
	}

	func identifier(for row: Int) -> Model.ID {
		return flattened[row]
	}

	func model(for row: Int) -> Model {
		let id = flattened[row]
		return snapshot.model(with: id)
	}

	func model(for id: Model.ID) -> Model {
		return snapshot.model(with: id)
	}

	func configuration(for row: Int) -> RowConfiguration {
		let id = flattened[row]
		return configuration(for: id)
	}

	func configuration(for id: Model.ID) -> RowConfiguration {
		return RowConfiguration(
			level: snapshot.level(for: id),
			isExpanded: expanded.contains(id),
			isLeaf: snapshot.isLeaf(id: id)
		)
	}

	func expanded(id: Model.ID) -> ListState {
		let newExpanded = expanded.union([id])
		return ListState(
			expanded: newExpanded,
			snapshot: snapshot
		)
	}

	func collapsed(id: Model.ID) -> ListState {
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

	func toggled(id: Model.ID) -> ListState {
		return expanded.contains(id) ? collapsed(id: id) : expanded(id: id)
	}

	func replaced(with snapshot: Snapshot<Model>) -> ListState {

		let newExpanded = expanded.intersection(snapshot.identifiers)

		return ListState(
			expanded: newExpanded,
			snapshot: snapshot
		)
	}

	func deleted(id: Model.ID) -> ListState {
		let nodes = snapshot.getNodes()
		let root = Root<Model>(hierarchy: nodes)
		root.deleteItem(id)
		let newExpanded = expanded.subtracting([id])
		return ListState(
			expanded: newExpanded,
			snapshot: Snapshot(root.nodes)
		)
	}

	func inserted(model: Model, to destination: Destination<Model.ID>) -> ListState {
		let root = Root<Model>(hierarchy: snapshot.getNodes())
		root.insertItems(with: [model], to: destination)

		return ListState(
			expanded: expanded,
			snapshot: Snapshot(root.nodes)
		)
	}
}

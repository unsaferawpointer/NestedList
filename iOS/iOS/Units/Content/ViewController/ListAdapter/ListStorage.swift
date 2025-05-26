//
//  ListDataSource.swift
//  iOS
//
//  Created by Anton Cherkasov on 07.01.2025.
//

import Foundation
import DesignSystem
import Hierarchy

final class ListStorage<Model: CellModel> {

	weak var delegate: (any CacheDelegate<Model>)?

	// MARK: - Internal State

	private var state = ListState<Model>()

	private var backupState: ListState<Model>?
}

extension ListStorage {

	func destination(for row: Int) -> Destination<Model.ID> {
		return state.destination(for: row)
	}

	var isEmpty: Bool {
		return state.isEmpty
	}
}

// MARK: - Moving support
extension ListStorage {

	func beginMovement(for id: Model.ID) {
		// Save current state
		self.backupState = state

		let newState = state.deleted(id: id)
		apply(newState: newState)
	}

	@discardableResult
	func endMovement(for id: Model.ID, to destination: Destination<Model.ID>) -> Destination<Model.ID> {
		defer {
			self.backupState = nil
		}
		guard let backupState else {
			fatalError("Incosistent state")
		}

		let resultDestination: Destination<Model.ID> = if
			backupState.snapshot.parent(for: id)?.id == destination.id,
			let rawIndex = destination.index,
			backupState.snapshot.localIndex(for: id) < rawIndex + 1
		{
			destination.shifted(by: 1)
		} else {
			destination
		}

		let model = backupState.model(for: id)

		let newState = state.inserted(model: model, to: destination)

		apply(newState: newState)

		return resultDestination

	}

	func cancelMovement() {
		guard let backupState else {
			return
		}
		apply(newState: backupState)
		self.backupState = nil
	}
}

// MARK: - Public interface
extension ListStorage {

	func apply(snapshot: Snapshot<Model>) {
		let newState = state.replaced(with: snapshot)
		apply(newState: newState)
	}

	var count: Int {
		return state.count
	}

	func row(for id: Model.ID) -> Int? {
		return state.row(for: id)
	}

	func apply(newSnapshot: Snapshot<Model>) {
		let newState = ListState<Model>(expanded: state.expanded, snapshot: newSnapshot)
		apply(newState: newState)
	}

	func rowConfiguration(for index: Int) -> RowConfiguration {
		return state.configuration(for: index)
	}

	func identifier(for row: Int) -> Model.ID {
		return state.identifier(for: row)
	}

	func model(with index: Int) -> Model {
		return state.model(for: index)
	}

	func toggle(indexPath: IndexPath) {

		let id = state.identifier(for: indexPath.row)
		let newState = state.toggled(id: id)

		apply(newState: newState)
	}

	func collapse(_ id: Model.ID) {
		let newState = state.collapsed(id: id)
		apply(newState: newState)
	}

	func expandAll() {
		let newState = state.allExpanded()
		apply(newState: newState)
	}

	func collapseAll() {
		let newState = state.allCollapsed()
		apply(newState: newState)
	}

	func expand(_ id: Model.ID) {
		let newState = state.expanded(id: id)
		apply(newState: newState)
	}
}

// MARK: - Helpers
private extension ListStorage {

	func apply(newState: ListState<Model>) {
		guard let delegate else {
			assertionFailure("Cannot animate without a delegate.")
			return
		}
		let oldState = state
		self.state = newState
		ListAnimator.update(oldState: oldState, newState: newState, delegate: delegate)
		ListAnimator.animate(oldState: oldState, newState: newState, delegate: delegate)
	}
}

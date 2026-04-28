//
//  ListManager.swift
//  iOS
//
//  Created by Anton Cherkasov on 07.01.2025.
//

import UIKit
import DesignSystem
import Hierarchy

struct RowConfiguration: Equatable {
	var level: Int
	var isExpanded: Bool
	var isLeaf: Bool
}

protocol CacheDelegate<Model>: AnyObject {

	associatedtype Model

	func updateCell(indexPath: IndexPath, rowConfiguration: RowConfiguration)
	func updateCell(indexPath: IndexPath, model: Model)
	func beginUpdates()
	func update(deleteRows: [IndexPath], insertRows: [IndexPath])
	func endUpdates()
}

@MainActor
final class ListManager<Model: CellModel & IdentifiableValue> {

	unowned var tableView: UITableView

	var delegate: (any ContentViewDelegate<Model.ID>)?

	var editingMode: EditingMode? {
		didSet {
			guard editingMode != oldValue else {
				return
			}
			tableView.setEditing(editingMode != nil, animated: true)
			tableView.allowsMultipleSelectionDuringEditing = editingMode?.allowSelection ?? false
			tableView.reloadData()
		}
	}

	private var feedbackGenerator = FeedbackGenerator()

	private let storage = ListStorage<Model>()

	var selection: [Model.ID] {
		get {
			tableView.indexPathsForSelectedRows?.map { indexPath in
				storage.identifier(for: indexPath.row)
			} ?? []
		}
	}

	// MARK: - Initialization

	init(tableView: UITableView, delegate: (any ContentViewDelegate<Model.ID>)?) {
		self.tableView = tableView

		self.tableView.register(ItemCell.self, forCellReuseIdentifier: "cell")
		self.storage.delegate = self
		self.delegate = delegate
	}
}

extension ListManager {

	func apply(newSnapshot: Snapshot<Model>) {
		storage.apply(newSnapshot: newSnapshot)
	}

	func scroll(to id: Model.ID) {
		guard let row = storage.row(for: id) else {
			return
		}
		tableView.scrollToRow(at: .init(row: row, section: 0), at: .bottom, animated: true)
	}

	func expand(_ id: Model.ID) {
		storage.expand(id)
	}

	func expandAll() {
		storage.expandAll()
	}

	func collapseAll() {
		storage.collapseAll()
	}

	func selectAll() {
		guard editingMode == .selection, storage.count > 0 else {
			return
		}
		for row in 0..<storage.count {
			tableView.selectRow(
				at: .init(row: row, section: 0),
				animated: false,
				scrollPosition: .none
			)
		}
		delegate?.listDidChangeSelection(ids: selection)
	}

	var isEmpty: Bool {
		storage.isEmpty
	}
}

// MARK: - UITableViewDataSource
extension ListManager {

	func numberOfRows() -> Int {
		return storage.count
	}

	func cellForRow(at indexPath: IndexPath) -> UITableViewCell {
		let cell = CellFactory.makeCell(with: Model.Cell.self, in: tableView, at: indexPath)

		let model = storage.model(with: indexPath.row)
		updateCell(cell, with: model)

		let configuration = storage.rowConfiguration(for: indexPath.row)
		updateCell(cell, with: configuration)

		return cell
	}
}

// MARK: - UITableViewDelegate
extension ListManager {

	func didSelect(at indexPath: IndexPath) {
		guard !tableView.isEditing else {
			delegate?.listDidChangeSelection(ids: selection)
			return
		}
		tableView.deselectRow(at: indexPath, animated: true)
		storage.toggle(indexPath: indexPath)
	}

	func didDeselectRow(at indexPath: IndexPath) {
		guard tableView.isEditing else {
			return
		}
		delegate?.listDidChangeSelection(ids: selection)
	}

	func contextMenuConfigurationForRow(at indexPath: IndexPath) -> UIContextMenuConfiguration? {
		guard !tableView.isEditing else {
			return nil
		}

		let model = storage.model(with: indexPath.row)

		return buildContextMenu(for: model)
	}

	func editingStyleForRow(at indexPath: IndexPath) -> UITableViewCell.EditingStyle {
		return .none
	}

	func commitEditingStyle(editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
		guard editingStyle == .delete else {
			return
		}
		let id = storage.identifier(for: indexPath.row)
		delegate?.listItemHasBeenDelete(id: id)
	}

	func shouldIndentWhileEditingRow(at indexPath: IndexPath) -> Bool {
		return editingMode == .selection
	}
}

// MARK: - UITableViewDragDelegate
extension ListManager {

	@MainActor
	func itemsForBeginning(session: any UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
		guard editingMode == .reordering, let delegate else {
			return []
		}

		let id = storage.model(with: indexPath.row).id
		guard let provider = delegate.provider(for: id) else {
			return []
		}
		let item = UIDragItem(itemProvider: provider)
		item.localObject = id
		return [item]
	}

}

// MARK: - UITableViewDropDelegate
extension ListManager {

	func tableView(_ tableView: UITableView, canHandle session: any UIDropSession) -> Bool {
		guard let types = delegate?.availableTypes() else {
			return false
		}
		return session.hasItemsConforming(toTypeIdentifiers: types)
	}

	func tableView(_ tableView: UITableView, dragSessionWillBegin session: any UIDragSession) {
		guard let item = session.items.first, let id = item.localObject as? Model.ID else {
			return
		}

		if let sceneIdentifier {
			session.localContext = sceneIdentifier
		}

		feedbackGenerator.impactOccurred(style: .heavy)

		storage.beginMovement(for: id)
	}

	func tableView(
		_ tableView: UITableView,
		dropSessionDidUpdate session: any UIDropSession,
		withDestinationIndexPath destinationIndexPath: IndexPath?
	) -> UITableViewDropProposal {

		guard isLocal(session: session) else {
			return .init(operation: .copy, intent: .automatic)
		}

		guard let target = destinationIndexPath?.row, target < storage.count else {
			return .init(operation: .move, intent: .automatic)
		}

		let id = session.identifiers(with: Model.ID.self).first

		assert(session.identifiers(with: Model.ID.self).count <= 1, "Adapter cant support multi-selection")

		// MARK: - You can't drop a cell on itself
		guard id != storage.identifier(for: target) else {
			return .init(operation: .cancel)
		}
		return .init(operation: .move, intent: .automatic)
	}

	func tableView(_ tableView: UITableView, dragSessionDidEnd session: any UIDragSession) {
		feedbackGenerator.impactOccurred(style: .medium)
		storage.cancelMovement()
	}

	func tableView(_ tableView: UITableView, performDropWith coordinator: any UITableViewDropCoordinator) {

		let proposal = coordinator.proposal
		let session = coordinator.session

		switch proposal.operation {
		case .copy:

			let targetIndexPath = coordinator.destinationIndexPath
			let destination = destination(
				for: proposal.intent,
				destinationIndexPath: targetIndexPath
			)

			let providers = session.items.map(\.itemProvider)

			delegate?.dropItems(providers: providers, to: destination)
		case .move:
			guard let id = coordinator.session.identifiers(with: Model.ID.self).first else {
				return
			}

			guard let target = coordinator.destinationIndexPath else {
				storage.endMovement(for: id, to: .toRoot)
				delegate?.move([id], to: .toRoot)
				return
			}

			switch proposal.intent {
			case .insertAtDestinationIndexPath:
				let destination = storage.destination(for: target.row)
				let newDestination = self.storage.endMovement(for: id, to: destination)
				self.delegate?.move([id], to: newDestination)
			case .insertIntoDestinationIndexPath:
				let model = storage.model(with: target.row)
				self.storage.endMovement(for: id, to: .onItem(with: model.id))
				self.delegate?.move([id], to: .onItem(with: model.id))
			default:
				return
			}
		default:
			return
		}
	}
}

// MARK: - Moving support
extension ListManager {

	func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
		return editingMode == .reordering
	}

	func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) { }

}

// MARK: - Drag And Drop Support
extension ListManager {

	var sceneIdentifier: String? {
		return tableView.window?.windowScene?
			.session.persistentIdentifier
	}

	func isLocal(session: any UIDropSession) -> Bool {
		guard let sceneIdentifier, let sessionIdentifier = session.localDragSession?.localContext as? String else {
			return false
		}
		return sessionIdentifier == sceneIdentifier
	}

	func storeIdentifier(to session: any UIDragSession) {
		session.localContext = sceneIdentifier
	}

	func destination(for intent: UITableViewDropProposal.Intent, destinationIndexPath: IndexPath?) -> Destination<Model.ID> {
		switch intent {
		case .insertAtDestinationIndexPath:
			return if let target = destinationIndexPath {
				storage.destination(for: target.row)
			} else {
				.toRoot
			}
		case .insertIntoDestinationIndexPath:
			guard let target = destinationIndexPath else {
				fatalError()
			}
			let model = storage.model(with: target.row)
			return .onItem(with: model.id)
		default:
			return .toRoot
		}
	}
}

// MARK: - Helpers
private extension ListManager {

	func updateCell(_ cell: Model.Cell, with configuration: RowConfiguration) {
		CellFactory.updateCell(cell, with: configuration)
	}

	func updateCell(_ cell: Model.Cell, with model: Model) {
		CellFactory.updateCell(cell, with: model, in: tableView, editingMode: editingMode)
	}
}

extension ListManager: CacheDelegate {

	func updateCell(indexPath: IndexPath, model: Model) {
		guard let cell = tableView.cellForRow(at: indexPath) as? Model.Cell else {
			return
		}

		updateCell(cell, with: model)
	}
	

	func updateCell(indexPath: IndexPath, rowConfiguration: RowConfiguration) {
		guard let cell = tableView.cellForRow(at: indexPath) as? Model.Cell else {
			return
		}

		updateCell(cell, with: rowConfiguration)
	}

	func beginUpdates() {
		tableView.beginUpdates()
	}

	func update(deleteRows: [IndexPath], insertRows: [IndexPath]) {
		tableView.deleteRows(at: deleteRows, with: .fade)
		tableView.insertRows(at: insertRows, with: .fade)
	}

	func endUpdates() {
		tableView.endUpdates()
	}
}

// MARK: - Context Menu Support
extension ListManager {

	func buildContextMenu(for model: Model) -> UIContextMenuConfiguration {
		guard let delegate else {
			fatalError("Delegate is nil")
		}
		return UIContextMenuConfiguration(actionProvider:  { _ in
			return DesignSystem.MenuBuilder.build(
				from: delegate.menu(for: [model.id]),
				with: [model.id],
				delegate: delegate
			)
		})
	}
}

fileprivate extension UIDropSession {

	func identifiers<T>(with type: T.Type) -> [T] {
		return items.compactMap {
			$0.localObject as? T
		}
	}
}

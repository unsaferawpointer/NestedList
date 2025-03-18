//
//  ListAdapter.swift
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

protocol CacheDelegate: AnyObject {
	func updateCell(indexPath: IndexPath, rowConfiguration: RowConfiguration)
	func updateCell(indexPath: IndexPath, model: ItemModel)
	func beginUpdates()
	func update(deleteRows: [IndexPath], insertRows: [IndexPath])
	func endUpdates()
}

enum EditingMode {
	case selection
	case reordering
}

final class ListAdapter: NSObject {

	weak var tableView: UITableView?

	var delegate: (any UnitViewDelegate<UUID>)?

	var editingMode: EditingMode? {
		didSet {
			tableView?.setEditing(editingMode != nil, animated: true)
			switch editingMode {
			case .selection:
				tableView?.allowsMultipleSelectionDuringEditing = true
			default:
				tableView?.allowsMultipleSelectionDuringEditing = false
			}
			let indexPaths = tableView?.indexPathsForVisibleRows ?? []
			tableView?.reloadRows(at: indexPaths, with: .none)
		}
	}

	var cache = ListDataSource()

	var selection: [UUID] {
		get {
			tableView?.indexPathsForSelectedRows?.map { indexPath in
				cache.identifier(for: indexPath.row)
			} ?? []
		}
	}

	var menuBuilder = MenuBuilder()

	// MARK: - Initialization

	init(tableView: UITableView?, delegate: (any UnitViewDelegate<UUID>)?) {
		self.tableView = tableView
		super.init()

		self.tableView?.dataSource = self
		self.tableView?.delegate = self
		self.tableView?.dragDelegate = self
		self.tableView?.dropDelegate = self

		self.tableView?.register(ItemCell.self, forCellReuseIdentifier: "cell")

		self.cache.delegate = self

		self.delegate = delegate
		self.menuBuilder.delegate = delegate
	}
}

// MARK: - Computed properties
extension ListAdapter {

	var sceneIdentifier: String? {
		return tableView?.superview?.window?.windowScene?.session.persistentIdentifier
	}
}

extension ListAdapter {

	func apply(newSnapshot: Snapshot<ItemModel>) {
		cache.apply(newSnapshot: newSnapshot)
	}

	func expand(_ id: UUID) {
		cache.expand(id)
	}

	func expandAll() {
		cache.expandAll()
	}

	var isEmpty: Bool {
		cache.list.isEmpty
	}
}

// MARK: - UITableViewDataSource
extension ListAdapter: UITableViewDataSource {

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return cache.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ItemCell
		cell.indentationWidth = 24
		cell.layoutMargins.left = 32
		cell.layoutMargins.right = 32

		let model = cache.model(with: indexPath.row)
		updateCell(cell, with: model)

		let configuration = cache.rowConfiguration(for: indexPath.row)
		updateCell(cell, with: configuration)

		return cell
	}
}

// MARK: - UITableViewDelegate
extension ListAdapter: UITableViewDelegate {

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		guard !tableView.isEditing else {
			delegate?.listDidChangeSelection(ids: selection)
			return
		}
		tableView.deselectRow(at: indexPath, animated: true)
		cache.toggle(indexPath: indexPath)
	}

	func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
		guard tableView.isEditing else {
			return
		}
		delegate?.listDidChangeSelection(ids: selection)
	}

	func tableView(
		_ tableView: UITableView,
		contextMenuConfigurationForRowAt indexPath: IndexPath,
		point: CGPoint
	) -> UIContextMenuConfiguration? {

		guard !tableView.isEditing else {
			return nil
		}

		let model = cache.model(with: indexPath.row)

		return buildContextMenu(for: model)
	}

	func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
		return .none
	}

	func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
		guard editingStyle == .delete else {
			return
		}
		let id = cache.identifier(for: indexPath.row)
		delegate?.listItemHasBeenDelete(id: id)
	}

	func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
		return editingMode == .selection
	}
}

// MARK: - UITableViewDragDelegate
extension ListAdapter: UITableViewDragDelegate {

	func tableView(
		_ tableView: UITableView,
		itemsForBeginning session: any UIDragSession,
		at indexPath: IndexPath
	) -> [UIDragItem] {
		guard tableView.isEditing, let delegate else {
			return []
		}

		let model = cache.model(with: indexPath.row)

		let string = delegate.string(for: model.id)
		let itemProvider = NSItemProvider(object: string as NSString)

		let item = UIDragItem(itemProvider: itemProvider)
		item.localObject = model.id
		return [item]
	}

}

extension ListAdapter: UITableViewDropDelegate {

	func tableView(_ tableView: UITableView, canHandle session: any UIDropSession) -> Bool {
		guard let delegate else {
			return false
		}
		let types = delegate.availableTypes()
		return session.hasItemsConforming(toTypeIdentifiers: types)
	}

	func tableView(_ tableView: UITableView, dragSessionWillBegin session: any UIDragSession) {
		guard let item = session.items.first, let id = item.localObject as? UUID else {
			return
		}
		cache.collapse(id)

		if let sceneIdentifier = tableView.superview?.window?.windowScene?.session.persistentIdentifier {
			session.localContext = sceneIdentifier
		}
	}

	func tableView(
		_ tableView: UITableView,
		dropSessionDidUpdate session: any UIDropSession,
		withDestinationIndexPath destinationIndexPath: IndexPath?
	) -> UITableViewDropProposal {

		let sessionIdentifier = session.localDragSession?.localContext as? String

		if sessionIdentifier != sceneIdentifier, destinationIndexPath != nil {
			return .init(operation: .copy, intent: .automatic)
		}

		let id = session.items.compactMap {
			$0.localObject as? UUID
		}.first

		guard let id, let target = destinationIndexPath?.row else {
			return .init(operation: .forbidden)
		}
		guard target < cache.count else {
			return .init(operation: .move, intent: .automatic)
		}
		guard id != cache.identifier(for: target) else {
			return .init(operation: .cancel)
		}
		return .init(operation: .move, intent: .automatic)
	}

	func tableView(_ tableView: UITableView, performDropWith coordinator: any UITableViewDropCoordinator) {
		let proposal = coordinator.proposal

		if proposal.operation == .copy {
			coordinator.session.loadObjects(ofClass: NSString.self) { [weak self] items in
				guard let self else {
					return
				}
				guard let strings = items as? [String] else { return }

				switch proposal.intent {
				case .insertAtDestinationIndexPath:
					let destination: Destination<UUID> = if let target = coordinator.destinationIndexPath {
						cache.destination(for: target.row)
					} else {
						.toRoot
					}
					delegate?.drop(strings, to: destination)
				case .insertIntoDestinationIndexPath:
					guard let target = coordinator.destinationIndexPath else {
						return
					}
					let model = cache.model(with: target.row)
					delegate?.drop(strings, to: .onItem(with: model.id))
				default:
					return
				}
			}
		}

		guard proposal.operation == .move, let target = coordinator.destinationIndexPath else {
			return
		}

		let ids = coordinator.session.items.compactMap {
			$0.localObject as? UUID
		}

		switch proposal.intent {
		case .insertAtDestinationIndexPath:
			let destination = cache.destination(for: target.row)
			delegate?.move(ids, to: destination)
		case .insertIntoDestinationIndexPath:
			let model = cache.model(with: target.row)
			delegate?.move(ids, to: .onItem(with: model.id))
		default:
			return
		}
	}
}

// MARK: - Moving support
extension ListAdapter {

	func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
		return editingMode == .reordering
	}

	func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) { }

}

// MARK: - Helpers
private extension ListAdapter {

	func updateCell(_ cell: ItemCell, with configuration: RowConfiguration) {

		let iconName = configuration.isExpanded ? "chevron.down" : "chevron.right"
		let image = UIImage(systemName: iconName)

		cell.accessoryView = !configuration.isLeaf ? UIImageView(image: image) : nil

		cell.indentationLevel = configuration.level
		cell.validateIndent()
	}

	func updateCell(_ cell: UITableViewCell, with model: ItemModel) {
		let configuration = {
			var configuration = UIListContentConfiguration.cell()

			let image: UIImage? = {
				if let iconConfiguration = model.icon {
					configuration.imageProperties.tintColor = iconConfiguration.token.color
					switch iconConfiguration.name {
					case .named(let name):
						return UIImage(named: name)
					case .systemName(let name):
						return UIImage(systemName: name)
					}
				} else {
					return nil
				}
			}()
			configuration.image = (tableView?.isEditing ?? false) && editingMode == .selection ? nil : image

			if let iconConfiguration = model.icon {
				configuration.imageProperties.tintColor = iconConfiguration.token.color
			}

			configuration.attributedText = .init(
				string: model.title.text,
				textColor: model.title.colorToken.color,
				strikethrough: model.title.strikethrough
			)

			configuration.textProperties.font = .preferredFont(forTextStyle: model.title.style)

			if let subtitleConfiguration = model.subtitle {
				configuration.secondaryTextProperties.font = .preferredFont(forTextStyle: subtitleConfiguration.style)
				configuration.secondaryTextProperties.color = subtitleConfiguration.colorToken.color
				configuration.secondaryText = subtitleConfiguration.text
			} else {
				configuration.secondaryText = nil
				configuration.secondaryText = nil
			}

			configuration.secondaryText = model.subtitle?.text

			return configuration
		}()

		cell.contentConfiguration = configuration
	}
}

extension ListAdapter: CacheDelegate {

	func updateCell(indexPath: IndexPath, model: ItemModel) {
		guard let cell = tableView?.cellForRow(at: indexPath) else {
			assertionFailure("Can't find cell")
			return
		}

		updateCell(cell, with: model)
	}
	

	func updateCell(indexPath: IndexPath, rowConfiguration: RowConfiguration) {
		guard let cell = tableView?.cellForRow(at: indexPath) as? ItemCell else {
			assertionFailure("Can't find cell")
			return
		}

		updateCell(cell, with: rowConfiguration)
	}

	func beginUpdates() {
		tableView?.beginUpdates()
	}

	func update(deleteRows: [IndexPath], insertRows: [IndexPath]) {
		tableView?.deleteRows(at: deleteRows, with: .fade)
		tableView?.insertRows(at: insertRows, with: .fade)
	}

	func endUpdates() {
		tableView?.endUpdates()
	}
}

// MARK: - Context Menu Support
extension ListAdapter {

	func buildContextMenu(for model: ItemModel) -> UIContextMenuConfiguration {
		return menuBuilder.buildConfiguration(for: model)
	}
}

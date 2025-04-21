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

final class ListAdapter: NSObject {

	weak var tableView: UITableView?

	var delegate: (any UnitViewDelegate<UUID>)?

	var editingMode: EditingMode? {
		didSet {
			tableView?.setEditing(editingMode != nil, animated: true)
			tableView?.allowsMultipleSelectionDuringEditing = editingMode?.allowSelection ?? false
			tableView?.reloadData()
		}
	}

	private var feedbackGenerator: UIImpactFeedbackGenerator?

	var cache = ListDataSource()

	var selection: [UUID] {
		get {
			tableView?.indexPathsForSelectedRows?.map { indexPath in
				cache.identifier(for: indexPath.row)
			} ?? []
		}
	}

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

	func collapseAll() {
		cache.collapseAll()
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
		guard editingMode == .reordering, let delegate else {
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

// MARK: - UITableViewDropDelegate
extension ListAdapter: UITableViewDropDelegate {

	func tableView(_ tableView: UITableView, canHandle session: any UIDropSession) -> Bool {
		guard let types = delegate?.availableTypes() else {
			return false
		}
		return session.hasItemsConforming(toTypeIdentifiers: types)
	}

	func tableView(_ tableView: UITableView, dragSessionWillBegin session: any UIDragSession) {
		guard let item = session.items.first, let id = item.localObject as? UUID else {
			return
		}

		// Тактильный отклик при перемещении элемента
		feedbackGenerator = UIImpactFeedbackGenerator(style: .heavy)
		feedbackGenerator?.prepare()
		feedbackGenerator?.impactOccurred()

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

		guard isLocal(session: session) else {
			return .init(operation: .copy, intent: .automatic)
		}

		guard let target = destinationIndexPath?.row, target < cache.count else {
			return .init(operation: .move, intent: .automatic)
		}

		let id = session.identifiers.first

		assert(session.identifiers.count <= 1, "Adapter cant support multi-selection")

		// MARK: - You can't drop a cell on itself
		guard id != cache.identifier(for: target) else {
			return .init(operation: .cancel)
		}
		return .init(operation: .move, intent: .automatic)
	}

	func tableView(_ tableView: UITableView, dragSessionDidEnd session: any UIDragSession) {
		// Завершаем работу генератора
		feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
		feedbackGenerator?.prepare()
		feedbackGenerator?.impactOccurred()
		feedbackGenerator = nil
	}

	func tableView(_ tableView: UITableView, performDropWith coordinator: any UITableViewDropCoordinator) {

		let proposal = coordinator.proposal

		switch proposal.operation {
		case .copy:
			coordinator.session.loadObjects(ofClass: NSString.self) { [weak self] items in
				guard let self else {
					return
				}
				guard let strings = items as? [String] else { return }

				let destination = destination(
					for: proposal.intent,
					destinationIndexPath: coordinator.destinationIndexPath
				)
				delegate?.drop(strings, to: destination)
			}
		case .move:
			let ids = coordinator.session.identifiers
			guard let target = coordinator.destinationIndexPath else {
				delegate?.move(ids, to: .toRoot)
				return
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

// MARK: - Drag And Drop Support
extension ListAdapter {

	var sceneIdentifier: String? {
		return tableView?.window?.windowScene?
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

	func destination(for intent: UITableViewDropProposal.Intent, destinationIndexPath: IndexPath?) -> Destination<UUID> {
		switch intent {
		case .insertAtDestinationIndexPath:
			return if let target = destinationIndexPath {
				cache.destination(for: target.row)
			} else {
				.toRoot
			}
		case .insertIntoDestinationIndexPath:
			guard let target = destinationIndexPath else {
				fatalError()
			}
			let model = cache.model(with: target.row)
			return .onItem(with: model.id)
		default:
			return .toRoot
		}
	}
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
					let symbolConfiguration = iconConfiguration.appearence.configuration
					switch iconConfiguration.name {
					case .named(let name):
						return UIImage(named: name)?
							.applyingSymbolConfiguration(symbolConfiguration)
					case .systemName(let name):
						return UIImage(systemName: name)?
							.applyingSymbolConfiguration(symbolConfiguration)
					}
				} else {
					return nil
				}
			}()
			configuration.image = (tableView?.isEditing ?? false) && editingMode == .selection
				? nil
				: image

			if let iconConfiguration = model.icon {
				configuration.imageProperties.tintColor = iconConfiguration.appearence.tint
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

	var identifiers: [UUID] {
		return items.compactMap {
			$0.localObject as? UUID
		}
	}
}

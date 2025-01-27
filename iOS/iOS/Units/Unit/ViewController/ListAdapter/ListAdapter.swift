//
//  ListAdapter.swift
//  iOS
//
//  Created by Anton Cherkasov on 07.01.2025.
//

import UIKit
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

	var invalidateState: Bool = false

	var cache = Cache()

	// MARK: - Initialization

	init(tableView: UITableView?, delegate: (any UnitViewDelegate<UUID>)?) {
		self.tableView = tableView
		super.init()

		self.tableView?.dataSource = self
		self.tableView?.delegate = self

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
}

// MARK: - UITableViewDataSource
extension ListAdapter: UITableViewDataSource {

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return cache.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
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
		tableView.deselectRow(at: indexPath, animated: true)
		cache.toggle(indexPath: indexPath)
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

	func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
		return false
	}
}

// MARK: - Helpers
private extension ListAdapter {

	func updateCell(_ cell: UITableViewCell, with configuration: RowConfiguration) {
		let iconName = configuration.isExpanded ? "chevron.down" : "chevron.right"
		let image = UIImage(systemName: iconName)

		cell.accessoryView = !configuration.isLeaf ? UIImageView(image: image) : nil
		cell.indentationLevel = configuration.level
	}

	func updateCell(_ cell: UITableViewCell, with model: ItemModel) {
		let configuration = {
			var configuration = UIListContentConfiguration.cell()

			configuration.imageProperties.tintColor = model.icon.token.color
			switch model.icon.name {
			case .named(let name):
				configuration.image = UIImage(named: name)
			case .systemName(let name):
				configuration.image = UIImage(systemName: name)
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
			} else {
				configuration.secondaryText = nil
			}

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
		guard let cell = tableView?.cellForRow(at: indexPath) else {
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
		return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { suggestedActions in

			let editItem = UIAction(title: "Edit...", image: UIImage(systemName: "pencil")) { [weak self] action in
				self?.delegate?.userTappedEditButton(id: model.id)
			}

			let editGroup = UIMenu(
				title: "", image: nil,
				identifier: nil,
				options: [.displayInline],
				preferredElementSize: .medium,
				children: [editItem]
			)
			editGroup.preferredElementSize = .large

			let newItem = UIAction(title: "New...", image: UIImage(systemName: "plus")) { [weak self] action in
				self?.delegate?.userTappedAddButton(target: model.id)
			}

			let cutItem = UIAction(title: "Cut", image: UIImage(systemName: "scissors")) { [weak self] action in
				self?.delegate?.userTappedCutButton(ids: [model.id])
			}

			let copyItem = UIAction(title: "Copy", image: UIImage(systemName: "document.on.document")) { [weak self] action in
				self?.delegate?.userTappedCopyButton(ids: [model.id])
			}

			let pasteItem = UIAction(title: "Paste", image: UIImage(systemName: "document.on.clipboard")) { [weak self] action in
				self?.delegate?.userTappedPasteButton(target: model.id)
			}

			let groupItem = UIMenu(
				title: "", image: nil,
				identifier: nil,
				options: [.displayInline],
				preferredElementSize: .large,
				children: [cutItem, copyItem, pasteItem]
			)

			let deleteItem = UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: .destructive) { [weak self] action in
				self?.delegate?.userTappedDeleteButton(ids: [model.id])
			}

			let statusItem = UIAction(
				title: "Completed",
				image: nil
			) { [weak self] action in
				self?.delegate?.userSetStatus(isDone: !model.status, id: model.id)
			}
			statusItem.state = model.status ? .on : .off

			let markItem = UIAction(
				title: "Marked",
				image: nil
			) { [weak self] action in
				self?.delegate?.userMark(isMarked: !model.isMarked, id: model.id)
			}
			markItem.state = model.isMarked ? .on : .off

			let statusGroup = UIMenu(
				title: "",
				image: nil,
				identifier: nil,
				options: [.displayInline],
				preferredElementSize: .large,
				children: [statusItem, markItem]
			)



			let defaultStyleItem = UIAction(
				title: "Item",
				image: nil
			) { [weak self] action in
				self?.delegate?.userSetStyle(style: .item, id: model.id)
			}

			let sectionStyleItem = UIAction(
				title: "Section",
				image: nil
			) { [weak self] action in
				self?.delegate?.userSetStyle(style: .section, id: model.id)
			}

			let styleGroup = UIMenu(
				title: "Style",
				image: nil,
				identifier: nil,
				options: [],
				preferredElementSize: .large,
				children: [defaultStyleItem, sectionStyleItem]
			)

			let menu = UIMenu(title: "", children: [newItem, statusGroup, editGroup, groupItem, styleGroup, deleteItem])

			return menu
		}
	}
}

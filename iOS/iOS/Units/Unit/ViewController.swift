//
//  ViewController.swift
//  iOS
//
//  Created by Anton Cherkasov on 16.11.2024.
//

import UIKit
import SwiftUI

import CoreModule
import DesignSystem
import Hierarchy
import UniformTypeIdentifiers

protocol UnitViewDelegate {
	func updateView()
	func userTappedCreateButton()
	func userTappedEditButton(id: UUID)
	func userTappedDeleteButton(ids: [UUID])
	func userTappedAddButton(target: UUID)
	func userSetStatus(isDone: Bool, id: UUID)
	func userTappedCutButton(ids: [UUID])
	func userTappedPasteButton(target: UUID)
	func userTappedCopyButton(ids: [UUID])

}

protocol UnitView: AnyObject {

	func display(_ snapshot: Snapshot<ItemModel>)

	func showDetails(with model: DetailsView.Model, completionHandler: @escaping (DetailsView.Model, Bool) -> Void)
	func hideDetails()

	func expand(_ id: UUID)
}

class ViewController: UIDocumentViewController {

	var delegate: UnitViewDelegate?

	var listDocument: Document? {
		self.document as? Document
	}

	override var document: UIDocument? {
		didSet {
			guard let document = listDocument else {
				return
			}
			self.delegate = UnitAssembly.build(self, storage: document.storage)
		}
	}

	// MARK: - UI-Properties

	lazy var tableView: UITableView = {
		let tableView = UITableView(frame: .zero, style: .plain)
		tableView.separatorStyle = .none

		tableView.dataSource = self
		tableView.delegate = self
		tableView.allowsMultipleSelection = false

		tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
		return tableView
	}()

	// MARK: - Data

	var expanded: Set<UUID> = []

	var snapshot = Snapshot<ItemModel>()

	override func loadView() {
		self.view = UIView()
		configureLayout()
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		navigationItem.trailingItemGroups = [
			.init(barButtonItems: [
				UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(add)),
				editButtonItem
			], representativeItem: nil)
		]

		tableView.reloadData()
	}

	override func setEditing(_ editing: Bool, animated: Bool) {
		super.setEditing(editing, animated: animated)

		tableView.setEditing(editing, animated: animated)
	}
}

// MARK: - Helpers
private extension ViewController {

	@objc
	func edit() {
		let isEditing = !tableView.isEditing

		editButtonItem.title = isEditing ? "Done" : "Edit"

		navigationItem.trailingItemGroups.first?.barButtonItems[1].title = isEditing ? "Done" : "Edit"
		tableView.setEditing(isEditing, animated: true)
	}

	@objc
	func add() {
		delegate?.userTappedCreateButton()
	}

	func animate(oldSnapshot: Snapshot<ItemModel>, newSnapshot: Snapshot<ItemModel>) {

		let ids = oldSnapshot.identifiers.intersection(newSnapshot.identifiers)

		let oldModels = oldSnapshot.flattened { item in
			self.expanded.contains(item.id)
		}

		let newModels = newSnapshot.flattened { item in
			self.expanded.contains(item.id)
		}

		for id in ids {
			guard
				oldSnapshot.index(for: id) == newSnapshot.index(for: id),
				oldSnapshot.isLeaf(id: id) != newSnapshot.isLeaf(id: id)
			else {
				continue
			}
			guard let index = oldModels.firstIndex(where: { $0.id == id }) else {
				continue
			}

			let cell = tableView.cellForRow(at: .init(row: index, section: 0))

			let isLeaf = newSnapshot.isLeaf(id: id)

			if isLeaf {
				cell?.accessoryView = nil
			} else {
				let isExpanded = expanded.contains(id)
				let iconName = isExpanded ? "chevron.down" : "chevron.right"
				let image = UIImage(systemName: iconName)

				cell?.accessoryView = UIImageView(image: image)
			}
		}

		self.snapshot = newSnapshot
		animate(oldModels: oldModels, newModels: newModels)
	}

	func animate(oldModels: [ItemModel], newModels: [ItemModel]) {

		let diff = newModels.difference(from: oldModels)

		tableView.beginUpdates()

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

		tableView.deleteRows(at: toRemove, with: .fade)
		tableView.insertRows(at: toInsert, with: .fade)

		tableView.endUpdates()
	}
}

// MARK: - DocumentView
extension ViewController: UnitView {

	func display(_ snapshot: Snapshot<ItemModel>) {
		if Thread.isMainThread {
			self.animate(oldSnapshot: self.snapshot, newSnapshot: snapshot)
		} else {
			DispatchQueue.main.async {
				self.animate(oldSnapshot: self.snapshot, newSnapshot: snapshot)
			}
		}

	}

	func showDetails(with model: DetailsView.Model, completionHandler: @escaping (DetailsView.Model, Bool) -> Void) {
		let details = DetailsView(item: model, completionHandler: completionHandler)
		let controller = UIHostingController(rootView: details)
		present(controller, animated: true)
	}

	func hideDetails() {
		presentedViewController?.dismiss(animated: true)
	}

	func expand(_ id: UUID) {
		let old = snapshot.flattened(while: { expanded.contains($0.id) })
		expanded.insert(id)
		let new = snapshot.flattened(while: { expanded.contains($0.id) })
		animate(oldModels: old, newModels: new)
	}

}

// MARK: - UITableViewDataSource
extension ViewController: UITableViewDataSource {

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		let models = snapshot.flattened { item in
			expanded.contains(item.id)
		}
		return models.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

		let models = snapshot.flattened { item in
			expanded.contains(item.id)
		}

		let model = models[indexPath.row]

		switch model.style {
		case .point:
			var configuration = UIListContentConfiguration.cell()
			configuration.attributedText = .init(
				string: model.text,
				textColor: model.textColor.color,
				strikethrough: model.strikethrough
			)
			configuration.image = UIImage(named: "point")
			cell.contentConfiguration = configuration
		case .section:
			var configuration = UIListContentConfiguration.cell()
			configuration.textProperties.font = .preferredFont(forTextStyle: .headline)
			configuration.attributedText = .init(
				string: model.text,
				textColor: model.textColor.color,
				strikethrough: model.strikethrough
			)
			configuration.image = nil
			cell.contentConfiguration = configuration
		}

		let level = snapshot.level(for: model.id)
		cell.indentationLevel = level
		cell.indentationWidth = 32
		cell.tintColor = .tertiaryLabel
		cell.layoutMargins.left = 32
		cell.layoutMargins.right = 32

		let isExpanded = expanded.contains(model.id)

		let iconName = isExpanded ? "chevron.down" : "chevron.right"
		let image = UIImage(systemName: iconName)

		let isNode = snapshot.numberOfChildren(ofItem: model.id) > 0
		cell.accessoryView = isNode ? UIImageView(image: image) : nil

		return cell
	}
}

// MARK: - UITableViewDelegate
extension ViewController: UITableViewDelegate {

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		let models = snapshot.flattened { item in
			expanded.contains(item.id)
		}
		let model = models[indexPath.row]

		let isNode = snapshot.numberOfChildren(ofItem: model.id) > 0

		guard isNode else {
			return
		}

		let cell = tableView.cellForRow(at: indexPath)

		let isExpanded = expanded.contains(model.id)

		if isExpanded {
			expanded.remove(model.id)
		} else {
			expanded.insert(model.id)
		}

		let iconName = !isExpanded ? "chevron.down" : "chevron.right"
		let image = UIImage(systemName: iconName)

		cell?.accessoryView = isNode ? UIImageView(image: image) : nil

		let newModels = snapshot.flattened { item in
			expanded.contains(item.id)
		}

		animate(oldModels: models, newModels: newModels)

	}

	func tableView(
		_ tableView: UITableView,
		contextMenuConfigurationForRowAt indexPath: IndexPath,
		point: CGPoint
	) -> UIContextMenuConfiguration? {

		let models = snapshot.flattened { item in
			expanded.contains(item.id)
		}
		let model = models[indexPath.row]

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

			let statusGroup = UIMenu(
				title: "",
				image: nil,
				identifier: nil,
				options: [.displayInline],
				preferredElementSize: .large,
				children: [statusItem]
			)

			statusItem.state = model.status ? .on : .off

			let menu = UIMenu(title: "", children: [newItem, editGroup, groupItem, statusGroup, deleteItem])

			return menu
		}

	}

	func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
		return .delete
	}

	func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {

		guard case .delete = editingStyle else {
			return
		}

		let models = snapshot.flattened { item in
			expanded.contains(item.id)
		}
		let model = models[indexPath.row]

		delegate?.userTappedDeleteButton(ids: [model.id])
	}
}

// MARK: - Helpers
private extension ViewController {

	func configureLayout() {
		[tableView].forEach {
			$0.translatesAutoresizingMaskIntoConstraints = false
			view.addSubview($0)
		}

		NSLayoutConstraint.activate(
			[
				tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
				tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
				tableView.topAnchor.constraint(equalTo: view.topAnchor),
				tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
			]
		)
	}
}

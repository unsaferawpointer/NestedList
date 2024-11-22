//
//  DocumentViewController.swift
//  iOS
//
//  Created by Anton Cherkasov on 16.11.2024.
//

import UIKit
import CoreModule
import DesignSystem
import Hierarchy

protocol UnitViewDelegate {
	func updateView()
	func createNew(target: UUID?)
}

protocol UnitView: AnyObject {
	func display(_ snapshot: Snapshot<ItemModel>)
}

class DocumentViewController: UIDocumentViewController {

	var delegate: UnitViewDelegate?

	var listDocument: Document? {
		self.document as? Document
	}

	override var document: UIDocument? {
		didSet {
			guard let document = listDocument else {
				return
			}
			print("is Main = \(Thread.isMainThread)")
			self.delegate = UnitAssembly.build(self, storage: document.storage)
		}
	}

	// MARK: - UI-Properties

	lazy var tableView: UITableView = {
		let tableView = UITableView(frame: .zero, style: .plain)
		tableView.separatorStyle = .none

		tableView.dataSource = self
		tableView.delegate = self

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
		tableView.reloadData()
	}
}

// MARK: - Helpers
private extension DocumentViewController {

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

		print("toRemove = \(toRemove)")
		print("toInsert = \(toInsert)")

		tableView.deleteRows(at: toRemove, with: .fade)
		tableView.insertRows(at: toInsert, with: .fade)

		tableView.endUpdates()


	}
}

// MARK: - DocumentView
extension DocumentViewController: UnitView {

	func display(_ snapshot: Snapshot<ItemModel>) {
		print("is Main = \(Thread.isMainThread)")
		DispatchQueue.main.async {
			self.animate(oldSnapshot: self.snapshot, newSnapshot: snapshot)
		}

	}

}

// MARK: - UITableViewDataSource
extension DocumentViewController: UITableViewDataSource {

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

		var configuration = UIListContentConfiguration.cell()
		configuration.text = model.title
		configuration.image = UIImage(named: "point")

		cell.contentConfiguration = configuration


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
extension DocumentViewController: UITableViewDelegate {

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

			// Create an action for sharing
			let newItem = UIAction(title: "New Item...", image: UIImage(systemName: "pencil")) { [weak self] action in
				self?.delegate?.createNew(target: model.id)
			}

			// Create other actions...

			return UIMenu(title: "", children: [newItem])
		}

	}
}

// MARK: - Helpers
private extension DocumentViewController {

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

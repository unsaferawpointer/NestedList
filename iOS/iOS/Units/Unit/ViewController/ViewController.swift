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

protocol UnitViewDelegate<ID>: DesignSystem.DropDelegate {

	associatedtype ID

	func updateView()
	func userTappedCreateButton()
	func userTappedEditButton(id: ID)
	func userTappedDeleteButton(ids: [ID])
	func userTappedAddButton(target: ID)
	func userSetStatus(isDone: Bool, id: ID)
	func userMark(isMarked: Bool, id: ID)
	func userSetStyle(style: Item.Style, id: ID)
	func userTappedCutButton(ids: [ID])
	func userTappedPasteButton(target: ID)
	func userTappedCopyButton(ids: [ID])

}

protocol UnitView: AnyObject {

	func display(_ snapshot: Snapshot<ItemModel>)

	func showDetails(with model: DetailsView.Model, completionHandler: @escaping (DetailsView.Properties, Bool) -> Void)
	func hideDetails()

	func expand(_ id: UUID)
}

class ViewController: UIDocumentViewController {

	var delegate: (any UnitViewDelegate<UUID>)?

	var listDocument: Document? {
		self.document as? Document
	}

	override func navigationItemDidUpdate() { }

	override var document: UIDocument? {
		didSet {
			guard let document = listDocument else {
				return
			}
			self.delegate = UnitAssembly.build(self, storage: document.storage)
			self.adapter = ListAdapter(tableView: tableView, delegate: delegate)
		}
	}

	override func updateContentUnavailableConfiguration(using state: UIContentUnavailableConfigurationState) {
		if adapter?.isEmpty ?? true {
			var configuration = UIContentUnavailableConfiguration.empty()
			configuration.text = "No items"
			configuration.secondaryText = "To add a new item, tap the «plus» button"
			self.contentUnavailableConfiguration = configuration
		} else {
			self.contentUnavailableConfiguration = nil
		}

	}

	// MARK: - UI-Properties

	lazy var tableView: UITableView = {
		let tableView = UITableView(frame: .zero, style: .plain)
		tableView.separatorStyle = .none

		tableView.allowsMultipleSelection = false

		tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
		return tableView
	}()

	// MARK: - Data

	var adapter: ListAdapter?

	override func loadView() {
		self.view = UIView()
		configureLayout()
	}

	override func viewDidLoad() {
		super.viewDidLoad()
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		let addButton = UIBarButtonItem(
			title: "Create New",
			image: .init(systemName: "plus"),
			target: self,
			action: #selector(add)
		)

		addButton.accessibilityIdentifier = "navigation-item-add"

		toolbarItems = [.flexibleSpace(), addButton]
		self.navigationController?.setToolbarHidden(false, animated: true)

	}

	override func setEditing(_ editing: Bool, animated: Bool) {
		super.setEditing(editing, animated: animated)

		tableView.setEditing(editing, animated: animated)
	}
}

// MARK: - Helpers
private extension ViewController {

	@objc
	func add() {
		delegate?.userTappedCreateButton()
	}
}

// MARK: - DocumentView
extension ViewController: UnitView {

	func display(_ snapshot: Snapshot<ItemModel>) {

		performUpdate { [weak self] in
			self?.adapter?.apply(newSnapshot: snapshot)
			self?.setNeedsUpdateContentUnavailableConfiguration()
		}
	}

	func showDetails(with model: DetailsView.Model, completionHandler: @escaping (DetailsView.Properties, Bool) -> Void) {
		let details = DetailsView(item: model, completionHandler: completionHandler)
		let controller = UIHostingController(rootView: details)
		present(controller, animated: true)
	}

	func hideDetails() {
		presentedViewController?.dismiss(animated: true)
	}

	func expand(_ id: UUID) {
		adapter?.expand(id)
	}

}

// MARK: - Helpers
private extension ViewController {

	func performUpdate(_ block: @escaping () -> Void) {
		if Thread.isMainThread {
			block()
		} else {
			DispatchQueue.main.async {
				block()
			}
		}
	}

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

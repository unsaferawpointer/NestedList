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
import CoreSettings
import Hierarchy
import UniformTypeIdentifiers

class ViewController: UIDocumentViewController {

	var delegate: (any UnitViewDelegate<UUID>)?

	// MARK: - Data

	var adapter: ListAdapter?

	var toolbarBuilder: ToolbarBuilder = ToolbarBuilder()

	var listDocument: Document? {
		self.document as? Document
	}

	override var document: UIDocument? {
		didSet {
			guard let document = listDocument else {
				return
			}
			self.delegate = UnitAssembly.build(self, storage: document.storage)
			self.toolbarBuilder.delegate = delegate
			self.adapter = ListAdapter(tableView: tableView, delegate: delegate)
		}
	}

	// MARK: - UI-Properties

	lazy var tableView: UITableView = {
		let tableView = UITableView(frame: .zero, style: .plain)
		tableView.separatorStyle = .none
		tableView.showsVerticalScrollIndicator = false

		tableView.allowsMultipleSelection = false

		tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
		return tableView
	}()

	// MARK: - View-Controller life - cycle

	override func loadView() {
		self.view = UIView()
		configureLayout()
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		delegate?.viewDidChange(state: .didLoad)
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		self.navigationController?.setToolbarHidden(false, animated: false)

		delegate?.viewDidChange(state: .didAppear)
	}

	override func updateContentUnavailableConfiguration(using state: UIContentUnavailableConfigurationState) {
		if adapter?.isEmpty ?? true {
			var configuration = UIContentUnavailableConfiguration.empty()
			configuration.text = "No items"
			configuration.secondaryText = "To add a new item, tap the '+' button."
			self.contentUnavailableConfiguration = configuration
		} else {
			self.contentUnavailableConfiguration = nil
		}
	}
}

// MARK: - DocumentView
extension ViewController: UnitView {

	func setEditing(_ editingMode: EditingMode?) {
		self.adapter?.editingMode = editingMode
	}

	func display(_ toolbar: ToolbarModel) {
		navigationItem.setRightBarButtonItems(toolbarBuilder.build(items: toolbar.top), animated: true)
		toolbarItems = toolbarBuilder.build(items: toolbar.bottom)
	}

	var selection: [UUID] {
		return adapter?.selection ?? []
	}

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

	func showSettings() {
		let settings = SettingsView(provider: SettingsProvider.shared)
		let controller = UIHostingController(rootView: settings)
		controller.title = "Settings"
		let navigationController = UINavigationController(rootViewController: controller)
		present(navigationController, animated: true)
	}

	func hideDetails() {
		presentedViewController?.dismiss(animated: true)
	}

	func expand(_ id: UUID) {
		adapter?.expand(id)
	}

	func expandAll() {
		adapter?.expandAll()
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
				tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
				tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
				tableView.topAnchor.constraint(equalTo: view.topAnchor),
				tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
			]
		)
	}
}

//
//  TableViewController.swift
//  iOS
//
//  Created by Anton Cherkasov on 16.11.2024.
//

import UIKit
import SwiftUI
import OSLog

import CoreModule
import DesignSystem
import Hierarchy
import UniformTypeIdentifiers

class TableViewController: UIViewController {

	// MARK: - DI

	let id: UUID?

	var delegate: (any ContentViewDelegate<UUID>)?

	// MARK: - Data

	var toolbarBuilder: ToolbarBuilder<UUID> = ToolbarBuilder<UUID>()

	// MARK: - UI-Properties

	lazy var nestedList: NestedList = {
		return NestedList()
	}()

	// MARK: - Initialization

	init(id: UUID?, configure: (TableViewController) -> Void) {
		self.id = id
		super.init(nibName: nil, bundle: nil)
		configure(self)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
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

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		(parent as? DocumentViewController)?.displayToolbar(top: [], bottom: [], showUndoGroup: false)
	}

	override func updateContentUnavailableConfiguration(using state: UIContentUnavailableConfigurationState) {
		if nestedList.isEmpty {
			var configuration = UIContentUnavailableConfiguration.empty()
			configuration.image = UIImage(systemName: "plus.square.on.square")
			configuration.imageProperties.tintColor = .quaternaryLabel
			configuration.text = String(localized: "empty-view-placeholder-text", table: "UnitLocalizable")
			configuration.secondaryText = String(localized: "empty-view-placeholder-secondary-text", table: "UnitLocalizable")
			self.contentUnavailableConfiguration = configuration
		} else {
			self.contentUnavailableConfiguration = nil
		}
	}
}

// MARK: - DocumentView
extension TableViewController: ContentView {

	func setEditing(_ editingMode: EditingMode?) {
		nestedList.setEditing(editingMode)
	}

	func display(_ toolbar: ToolbarModel) {

		let topItems = ToolbarBuilder.build(from: toolbar.top, delegate: delegate) ?? []
		let bottomItems = ToolbarBuilder.build(from: toolbar.bottom, delegate: delegate) ?? []

		(parent as? DocumentViewController)?
			.displayToolbar(
				top: topItems,
				bottom: bottomItems,
				showUndoGroup: toolbar.showUndoGroup
			)
	}

	var selection: [UUID] {
		nestedList.selection
	}

	func display(_ snapshot: Snapshot<ItemModel>) {
		nestedList.display(snapshot)
		self.setNeedsUpdateContentUnavailableConfiguration()
	}

	func expand(_ id: UUID) {
		nestedList.expand(id)
	}

	func scroll(to id: UUID) {
		nestedList.scroll(to: id)
	}

	func expandAll() {
		nestedList.expandAll()
	}

	func collapseAll() {
		nestedList.collapseAll()
	}

	func selectAll() {
		nestedList.selectAll()
	}

}

// MARK: - Helpers
private extension TableViewController {

	func configureLayout() {
		nestedList.pin(edges: .all, to: view)
	}
}

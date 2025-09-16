//
//  ContentViewController.swift
//  iOS
//
//  Created by Anton Cherkasov on 16.11.2024.
//

import UIKit
import SwiftUI
import OSLog

import CoreModule
import DesignSystem
import CoreSettings
import Hierarchy
import UniformTypeIdentifiers

class ContentViewController: UIDocumentViewController {

	// MARK: - DI

	lazy var router: Router = {
		return Router(root: self)
	}()

	var delegate: (any ContentViewDelegate<UUID>)?

	// MARK: - Data

	var toolbarBuilder: ToolbarBuilder<UUID> = ToolbarBuilder<UUID>()

	var listDocument: Document? {
		self.document as? Document
	}

	var undoRedoItems: [UIBarButtonItem] = []

	override var document: UIDocument? {
		didSet {
			loadViewIfNeeded()
		}
	}

	// MARK: - UI-Properties

	lazy var nestedList: NestedList = {
		return NestedList(frame: .zero)
	}()

	// MARK: - View-Controller life - cycle

	override func loadView() {
		self.view = UIView()
		configureLayout()
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		configureViewForCurrentDocument()
		undoRedoItems = undoRedoItemGroup.barButtonItems
		delegate?.viewDidChange(state: .didLoad)
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		self.navigationController?.setToolbarHidden(false, animated: false)

		delegate?.viewDidChange(state: .didAppear)
	}

	override func documentDidOpen() {
		configureViewForCurrentDocument()
	}

	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)

		document?.close { (success) in
			guard success else { fatalError( "*** Error closing document ***") }

			os_log("==> Document saved and closed", log: .default, type: .debug)
		}
	}

	override func updateContentUnavailableConfiguration(using state: UIContentUnavailableConfigurationState) {
		if nestedList.isEmpty {
			var configuration = UIContentUnavailableConfiguration.empty()
			configuration.text = String(localized: "empty-view-placeholder-text", table: "UnitLocalizable")
			configuration.secondaryText = String(localized: "empty-view-placeholder-secondary-text", table: "UnitLocalizable")
			self.contentUnavailableConfiguration = configuration
		} else {
			self.contentUnavailableConfiguration = nil
		}
	}
}

// MARK: - Helpers
private extension ContentViewController {

	func configureViewForCurrentDocument() {
		guard let document = listDocument else {
			return
		}
		self.delegate = ContentUnitAssembly.build(self, storage: document.storage)
		self.nestedList.setDelegate(delegate)
	}
}

// MARK: - RouterProtocol
extension ContentViewController: RouterProtocol {

	func showDetails(with model: DetailsView.Model, completionHandler: @escaping (DetailsView.Properties, Bool) -> Void) {
		router.showDetails(with: model, completionHandler: completionHandler)
	}

	func showSettings() {
		router.showSettings()
	}

	func hideDetails() {
		router.hideDetails()
	}
}

// MARK: - DocumentView
extension ContentViewController: ContentView {

	func setEditing(_ editingMode: EditingMode?) {
		nestedList.setEditing(editingMode)
	}

	func display(_ toolbar: ToolbarModel) {
		let topItems = DesignSystem.ToolbarBuilder.build(from: toolbar.top, delegate: delegate) ?? []
		navigationItem.setRightBarButtonItems(topItems, animated: true)

		toolbarItems = undoRedoItems + (DesignSystem.ToolbarBuilder.build(from: toolbar.bottom, delegate: delegate) ?? [])
	}

	var selection: [UUID] {
		nestedList.selection
	}

	func display(_ snapshot: Snapshot<ItemModel>) {
		nestedList.display(snapshot)
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

}

// MARK: - Helpers
private extension ContentViewController {

	func configureLayout() {
		nestedList.pin(edges: .all, to: view)
	}
}

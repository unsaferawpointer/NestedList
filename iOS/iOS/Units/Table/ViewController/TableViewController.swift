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

	private var toolbarBuilder = ContentToolbarBuilder<UUID>()

	private var displaysToolbarAnimated = true

	// MARK: - UI-Properties

	lazy var nestedList: NestedList = {
		return NestedList()
	}()

	private lazy var pathView: PathView = {
		let view = PathView()
		view.didSelectItem = { [weak self] id in
			self?.delegate?.selectPathComponent(id)
		}
		return view
	}()

	private let placeholderView = UIContentUnavailableView(configuration: .empty())
	private var placeholderBottomConstraint: NSLayoutConstraint?

	// MARK: - Initialization

	init(id: UUID?, configure: @MainActor (TableViewController) -> Void) {
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
		configureScrollEdgeInteraction()
		delegate?.viewDidChange(state: .didLoad)
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		updateScrollInsets()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		navigationController?.setToolbarHidden(false, animated: false)
		displaysToolbarAnimated = false
		delegate?.viewDidChange(state: .willAppear)
		displaysToolbarAnimated = true
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
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
			placeholderView.configuration = configuration
			placeholderView.isHidden = false
		} else {
			placeholderView.isHidden = true
		}
	}
}

// MARK: - DocumentView
extension TableViewController: ContentView {

	func setEditing(_ editingMode: EditingMode?) {
		nestedList.setEditing(editingMode)
	}

	func apply(_ configuration: ContentToolbarConfiguration<UUID>) {
		let toolbar = toolbarBuilder.build(configuration: configuration, delegate: delegate)
		display(
			top: toolbar.top,
			topMenuElements: toolbar.topMenuElements,
			bottom: toolbar.bottom,
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

	func display(title: String) {
		self.title = title
	}

	func displayPath(_ items: [PathItem]) {
		pathView.display(items)
		view.setNeedsLayout()
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

	var documentViewController: DocumentViewController? {
		navigationController?.viewControllers
			.compactMap { $0 as? DocumentViewController }
			.first
	}

	func display(
		top: [UIBarButtonItem],
		topMenuElements: [UIMenuElement],
		bottom: [UIBarButtonItem],
		showUndoGroup: Bool
	) {
		guard let root = parent as? DocumentViewController else {
			navigationItem.setRightBarButtonItems(top, animated: true)
			toolbarItems = documentViewController?.makeBottomToolbarItems(
				bottom: bottom,
				showUndoGroup: showUndoGroup
			) ?? bottom
			return
		}

		root.displayToolbar(
			top: top,
			topMenuElements: topMenuElements,
			bottom: bottom,
			showUndoGroup: showUndoGroup,
			animated: displaysToolbarAnimated
		)
	}

	func configureLayout() {
		nestedList.pin(edges: .all, to: view)
		pathView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(pathView)
		placeholderView.translatesAutoresizingMaskIntoConstraints = false
		placeholderView.isHidden = true
		nestedList.addSubview(placeholderView)
		let placeholderBottom = placeholderView.bottomAnchor.constraint(equalTo: nestedList.safeAreaLayoutGuide.bottomAnchor)
		placeholderBottomConstraint = placeholderBottom
		NSLayoutConstraint.activate([
			pathView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			pathView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			pathView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
			placeholderView.leadingAnchor.constraint(equalTo: nestedList.safeAreaLayoutGuide.leadingAnchor),
			placeholderView.trailingAnchor.constraint(equalTo: nestedList.safeAreaLayoutGuide.trailingAnchor),
			placeholderView.topAnchor.constraint(equalTo: nestedList.safeAreaLayoutGuide.topAnchor),
			placeholderBottom
		])
	}

	func configureScrollEdgeInteraction() {
		if #available(iOS 26.0, *) {
			let interaction = UIScrollEdgeElementContainerInteraction()
			interaction.scrollView = nestedList.tableView
			interaction.edge = .bottom
			pathView.addInteraction(interaction)
		} else {
			pathView.backgroundColor = .systemBackground
		}
	}

	func updateScrollInsets() {
		let bottomInset = pathView.isHidden ? 0 : pathView.bounds.height
		nestedList.tableView.contentInset.bottom = bottomInset
		nestedList.tableView.verticalScrollIndicatorInsets.bottom = bottomInset
		placeholderBottomConstraint?.constant = -bottomInset
	}
}

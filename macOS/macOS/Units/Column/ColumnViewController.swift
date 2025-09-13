//
//  ColumnViewController.swift
//  Nested List
//
//  Created by Anton Cherkasov on 16.08.2025.
//

import AppKit
import SwiftUI
import CoreModule
import DesignSystem

protocol ColumnViewOutput: ViewDelegate, MenuDelegate {
	func userClickedOnPlusButton()
	func configure(for id: UUID)
}

protocol ColumnUnitView: AnyObject, ListSupportable {
	func display(_ model: ColumnModel)
	func hideDetails()
	func showDetails(
		with model: ItemDetailsView.Model,
		completionHandler: @escaping (ItemDetailsView.Properties, Bool) -> Void
	)
}

class ColumnViewController: NSCollectionViewItem {

	private var columns: [UUID] = []

	// MARK: - DI

	var output: ColumnViewOutput?

	lazy var router: Router = {
		return .init(root: self)
	}()


	// MARK: - UI

	var content: ContentViewController?

	lazy var headerView: ColumnHeaderView = {
		let view = ColumnHeaderView(menu: nil)
		view.leadingAction = { [weak self] in
			self?.output?.userClickedOnPlusButton()
		}
		return view
	}()

	lazy var backgroundView: NSBox = {
		let view = NSBox()
		view.boxType = .primary
		view.titlePosition = .noTitle
		view.title = ""
		return view
	}()

	// MARK: - Initialization

	override init(nibName nibNameOrNil: NSNib.Name?, bundle nibBundleOrNil: Bundle?) {
		super.init(nibName: nil, bundle: nil)
	}

	init(_ content: ContentViewController, configure: (ColumnViewController) -> Void) {
		self.content = content
		super.init(nibName: nil, bundle: nil)
		configure(self)
	}

	@available(*, unavailable, message: "Use init(storage:)")
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - View life-cycle

	override func loadView() {
		self.view = NSView()
		configureUserInterface()
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		output?.viewDidChange(state: .didLoad)
	}

	override func viewWillAppear() {
		super.viewWillAppear()
		output?.viewDidChange(state: .willAppear)
	}
}

// MARK: - ListSupportable
extension ColumnViewController: ListSupportable {

	func expand(_ ids: [UUID]?) {
		content?.expand(ids)
	}

	func scroll(to id: UUID) {
		content?.scroll(to: id)
	}

	func select(_ id: UUID) {
		content?.select(id)
	}

	func focus(on id: UUID, key: String) {
		content?.focus(on: id, key: key)
	}

	var selection: [UUID] {
		content?.selection ?? []
	}
}

extension ColumnViewController {

	func configure(for id: UUID, with storage: DocumentStorage<Content>) {
		if let content {
			output?.configure(for: id)
			content.configure(for: id)
		} else {
			self.content = ContentUnitAssembly.build(
				for: id,
				storage: storage,
				configuration: .init(drawsBackground: false, hasInsets: false)
			)

			ColumnUnitAssembly.configure(column: self, root: id, storage: storage)

			let menu = MenuBuilder.build(
				for: output?.menuItems() ?? [],
				target: self
			)
			headerView.buttonMenu = menu
			configureUserInterface()
			output?.configure(for: id)
		}
	}
}

// MARK: - ColumnUnitView
extension ColumnViewController: ColumnUnitView {

	func display(_ model: ColumnModel) {
		headerView.model = model
	}

	func hideDetails() {
		if let sheet = presentedViewControllers?.first {
			DispatchQueue.main.async { [weak self] in
				self?.dismiss(sheet)
			}
		}
	}

	func showDetails(with model: ItemDetailsView.Model, completionHandler: @escaping (ItemDetailsView.Properties, Bool) -> Void) {
		router.showDetails(with: model, completionHandler: completionHandler)
	}
}

// MARK: - Actions
extension ColumnViewController {

	@objc
	func menuItemClicked(_ sender: NSMenuItem) {
		guard let rawValue = sender.identifier?.rawValue else {
			return
		}
		let id = ElementIdentifier(rawValue: rawValue)
		output?.menuItemClicked(id)
	}
}

// MARK: - NSMenuItemValidation
extension ColumnViewController: NSMenuItemValidation {

	func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {

		guard let rawValue = menuItem.identifier?.rawValue, let output else {
			return false
		}

		let id = ElementIdentifier(rawValue: rawValue)

		menuItem.state = output.stateForMenuItem(id).value
		menuItem.isHidden = output.isHidden(id)
		return output.validateMenuItem(id)
	}
}

// MARK: - Helpers
private extension ColumnViewController {

	func configureUserInterface() {

		guard let content else {
			return
		}

		addChild(content)

		backgroundView.pin(edges: [.leading, .top, .bottom, .trailing], to: view, with: 12)
		content.view.pin(edges: [.leading, .bottom, .trailing], to: backgroundView, with: 0)
		headerView.pin(edges: [.leading, .top, .trailing], to: backgroundView)

		NSLayoutConstraint.activate(
			[
				headerView.bottomAnchor.constraint(equalTo: content.view.topAnchor)
			]
		)
	}
}

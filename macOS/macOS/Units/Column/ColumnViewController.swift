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
}

protocol ColumnUnitView: AnyObject, ListSupportable {
	func display(_ title: String)
	func hideDetails()
	func showDetails(
		with model: DetailsView.Model,
		completionHandler: @escaping (DetailsView.Properties, Bool) -> Void
	)
}

class ColumnViewController: NSCollectionViewItem {

	private var columns: [UUID] = []

	// MARK: - DI

	var output: ColumnViewOutput?

	// MARK: - UI

	var content: ContentViewController

	lazy var headerView: ColumnHeaderView = {
		let menu = MenuBuilder.build(
			for: output?.menuItems() ?? [],
			target: self
		)
		let view = ColumnHeaderView(menu: menu)
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
		configureConstraints()
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
		content.expand(ids)
	}

	func scroll(to id: UUID) {
		content.scroll(to: id)
	}

	func select(_ id: UUID) {
		content.select(id)
	}

	func focus(on id: UUID, key: String) {
		content.focus(on: id, key: key)
	}

	var selection: [UUID] {
		content.selection
	}
}

// MARK: - ColumnUnitView
extension ColumnViewController: ColumnUnitView {

	func display(_ title: String) {
		headerView.titleTextfield.stringValue = title
	}

	func hideDetails() {
		if let sheet = presentedViewControllers?.first {
			dismiss(sheet)
		}
	}

	func showDetails(with model: DetailsView.Model, completionHandler: @escaping (DetailsView.Properties, Bool) -> Void) {

		let contentViewController = NSHostingController(
			rootView:
				DetailsView(item: model, completionHandler: completionHandler)
		)
		contentViewController.title = model.navigationTitle
		presentAsSheet(contentViewController)
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

		return true

//		guard let rawValue = menuItem.identifier?.rawValue, let output else {
//			return false
//		}
//
//		let id = ElementIdentifier(rawValue: rawValue)
//
//		menuItem.state = output.stateForMenuItem(id).value
//		menuItem.isHidden = output.isHidden(id)
//		return output.validateMenuItem(id)
	}
}

// MARK: - Helpers
private extension ColumnViewController {

	func configureUserInterface() {

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

	func configureConstraints() {

	}

}

//
//  ColumnViewController.swift
//  Nested List
//
//  Created by Anton Cherkasov on 16.08.2025.
//

import AppKit
import CoreModule
import DesignSystem

protocol ColumnViewOutput: ViewDelegate, MenuDelegate { }

protocol ColumnUnitView: AnyObject {
	func display(_ title: String)
}

class ColumnViewController: NSCollectionViewItem {

	private var columns: [UUID] = []

	// MARK: - DI

	var output: ColumnViewOutput?

	// MARK: - UI

	var content: NSViewController

	lazy var headerView: ColumnHeaderView = {
		let menu = MenuBuilder.build(
			for: output?.menuItems() ?? [],
			target: self
		)
		let view = ColumnHeaderView(menu: menu)
		return view
	}()

	lazy var scrollview: NSScrollView = {
		let view = NSScrollView()
		view.borderType = .noBorder
		view.hasHorizontalScroller = false
		view.autohidesScrollers = true
		view.hasVerticalScroller = false
		view.automaticallyAdjustsContentInsets = true
		return view
	}()

	lazy var backgroundView: NSView = {
		let view = NSView()
		view.wantsLayer = true
		if #available(macOS 14.0, *) {
			view.layer?.backgroundColor = NSColor.tertiarySystemFill.cgColor
		} else {
			// Fallback on earlier versions
		}
		view.layer?.cornerRadius = 8
		return view
	}()

	override func viewDidLayout() {
		super.viewDidLayout()
		if #available(macOS 14.0, *) {
			backgroundView.layer?.backgroundColor = ColorToken.gray.value.withAlphaComponent(0.05).cgColor
		} else {
			// Fallback on earlier versions
		}
	}

	// MARK: - Initialization

	init(_ content: NSViewController, configure: (ColumnViewController) -> Void) {
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

// MARK: - ColumnUnitView
extension ColumnViewController: ColumnUnitView {

	func display(_ title: String) {
		headerView.titleTextfield.stringValue = title
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

		backgroundView.pin(edges: [.leading, .bottom, .trailing], to: view, with: 12)
		headerView.pin(edges: [.leading, .top, .trailing], to: view, with: 12)
		content.view.pin(edges: .all, to: backgroundView, with: 0)

		NSLayoutConstraint.activate(
			[
				headerView.bottomAnchor.constraint(equalTo: backgroundView.topAnchor)
			]
		)
	}

	func configureConstraints() {

	}

}

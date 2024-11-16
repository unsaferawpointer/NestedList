//
//  ViewController.swift
//  macOS
//
//  Created by Anton Cherkasov on 16.11.2024.
//

import Cocoa
import Hierarchy
import DesignSystem

protocol UnitView {
	func display(_ snapshot: Snapshot<ItemModel>)
}

class ViewController: NSViewController {

	var adapter: ListAdapter<ItemModel>?

	// MARK: - UI-Properties

	lazy var scrollview: NSScrollView = {
		let view = NSScrollView()
		view.borderType = .noBorder
		view.hasHorizontalScroller = false
		view.autohidesScrollers = true
		view.hasVerticalScroller = true
		view.automaticallyAdjustsContentInsets = true
		return view
	}()

	lazy var table: NSOutlineView = {
		let view = NSOutlineView()
		view.style = .inset
		view.rowSizeStyle = .default
		view.floatsGroupRows = false
		view.allowsMultipleSelection = true
		view.allowsColumnResizing = false
		view.usesAlternatingRowBackgroundColors = true
		view.usesAutomaticRowHeights = false
		view.indentationPerLevel = 24
		return view
	}()

	// MARK: - View life-cycle

	override func loadView() {
		self.view = NSView()
		configureUserInterface()
		configureConstraints()
		adapter = ListAdapter<ItemModel>(tableView: table)
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		let new = Snapshot<ItemModel>.init(
			[
				.init(
					value: .init(
						id: .init(),
						value: .init(
							isOn: true,
							text: "New Item"
						),
						configuration: .init(textColor: .labelColor)
					)
					, children:
						[
							.init(
								value: .init(
									id: .init(),
									value: .init(
										isOn: true,
										text: "New Item"
									),
									configuration: .init(textColor: .labelColor)
								)
							),
							.init(
								value: .init(
									id: .init(),
									value: .init(
										isOn: true,
										text: "New Item"
									),
									configuration: .init(textColor: .labelColor)
								)
							),
							.init(
								value: .init(
									id: .init(),
									value: .init(
										isOn: true,
										text: "New Item"
									),
									configuration: .init(textColor: .labelColor)
								)
							)
						]
				)
			]
		)

		adapter?.apply(new)
	}

	override func viewWillAppear() {
		super.viewWillAppear()
		table.sizeLastColumnToFit()
	}
}

// MARK: - UnitView
extension ViewController: UnitView {

	func display(_ snapshot: Snapshot<ItemModel>) {

		let new = Snapshot<ItemModel>.init(
			[
				.init(value: .init(id: .init(), value: .init(isOn: true, text: "New Item"), configuration: .init(textColor: .labelColor)))
			]
		)

		adapter?.apply(new)
	}
}

// MARK: - Helpers
private extension ViewController {

	func configureUserInterface() {

		table.frame = scrollview.bounds
		table.headerView = nil

		let column = NSTableColumn(identifier: .init("main"))
		table.addTableColumn(column)

		scrollview.documentView = table
	}

	func configureConstraints() {
		[scrollview].forEach {
			view.addSubview($0)
			$0.translatesAutoresizingMaskIntoConstraints = false
		}

		NSLayoutConstraint.activate(
			[
				scrollview.leadingAnchor.constraint(equalTo: view.leadingAnchor),
				scrollview.trailingAnchor.constraint(equalTo: view.trailingAnchor),
				scrollview.topAnchor.constraint(equalTo: view.topAnchor),
				scrollview.bottomAnchor.constraint(equalTo: view.bottomAnchor)
			]
		)
	}
}

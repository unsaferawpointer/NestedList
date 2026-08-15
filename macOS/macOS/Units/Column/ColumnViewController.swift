//
//  ColumnViewController.swift
//  macOS
//

import AppKit
import SwiftUI
import CoreModule
import DesignSystem

/// The Column view interface.
protocol ColumnUnitView: AnyObject, ListSupportable {
	func display(_ model: ColumnModel)
}

/// The Column view controller.
class ColumnViewController: NSCollectionViewItem {

	private var columns: [UUID] = []

	// MARK: - DI

	var output: (any ColumnViewOutput)?

	// MARK: - UI

	var content: ContentViewController?

	lazy var headerView: ColumnHeaderView = {
		let view = ColumnHeaderView(menu: nil)
		view.leadingAction = { [weak self] in
			// TODO: - Implement
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

	func configure(for id: UUID, with storage: DocumentStorage<DocumentContent>) {
		if let content {
			output?.configure(for: id)
//			content.configure(for: id)
		} else {
			self.content = ContentUnitAssembly.build(for: id, storage: storage)

			ColumnUnitAssembly.configure(column: self, root: id, storage: storage)

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
}

// MARK: - Helpers
private extension ColumnViewController {

	func configureUserInterface() {

		guard let content else {
			return
		}

		addChild(content)

		backgroundView.pin(edges: [.leading, .trailing], to: view, with: 8)
		backgroundView.pin(edges: [.top, .bottom], to: view, with: 8)
		content.view.pin(edges: [.leading, .bottom, .trailing], to: backgroundView, with: 0)
		headerView.pin(edges: [.leading, .top, .trailing], to: backgroundView)

		NSLayoutConstraint.activate(
			[
				headerView.bottomAnchor.constraint(equalTo: content.view.topAnchor)
			]
		)
	}
}

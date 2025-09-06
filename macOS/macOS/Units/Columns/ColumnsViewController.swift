//
//  ColumnsViewController.swift
//  Nested List
//
//  Created by Anton Cherkasov on 14.08.2025.
//

import AppKit
import SwiftUI
import DesignSystem
import CoreModule

protocol ColumnsViewOutput: ViewDelegate {
	func handleNewColumnClick()
}

protocol ColumnsUnitView: AnyObject {
	func display(state: ColumnsViewState)
}

class ColumnsViewController: NSViewController {

	private var columns: [UUID] = []

	// MARK: - DI

	var output: ColumnsViewOutput?

	let storage: DocumentStorage<Content>

	// MARK: - UI

	var placeholderView: NSView?

	lazy var scrollview: NSScrollView = {
		let view = NSScrollView()
		view.borderType = .noBorder
		view.hasHorizontalScroller = false
		view.autohidesScrollers = true
		view.hasVerticalScroller = false
		view.automaticallyAdjustsContentInsets = true
		return view
	}()

	lazy var collectionView: NSCollectionView = {
		let view = NSCollectionView()
		return view
	}()

	// MARK: - Initialization

	init(storage: DocumentStorage<Content>, configure: (ColumnsViewController) -> Void) {
		self.storage = storage
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
		configureLayout()
		configureConstraints()
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		collectionView.register(ColumnViewController.self, forItemWithIdentifier: .init("column"))
		collectionView.dataSource = self
		collectionView.delegate = self

		output?.viewDidChange(state: .didLoad)
	}

	override func viewWillAppear() {
		super.viewWillAppear()
		output?.viewDidChange(state: .willAppear)
	}
}

// MARK: - Actions
extension ColumnsViewController: DocumentToolbarSupportable {

	func newItem(_ sender: Any) {
		output?.handleNewColumnClick()
	}
}

// MARK: - Helpers
private extension ColumnsViewController {

	func configureUserInterface() {
		collectionView.frame = scrollview.bounds
		scrollview.documentView = collectionView
	}

	func configureConstraints() {
		scrollview.pin(edges: .all, to: view)
	}

	func configureLayout() {

		let layout = NSCollectionViewGridLayout()
		layout.maximumNumberOfRows = 1
		layout.minimumInteritemSpacing = 24
		layout.minimumLineSpacing = 0
		layout.minimumItemSize.width = 240

		collectionView.collectionViewLayout = layout
	}
}

// MARK: - NSCollectionViewDataSource
extension ColumnsViewController: NSCollectionViewDataSource {

	func numberOfSections(in collectionView: NSCollectionView) -> Int {
		1
	}

	func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
		columns.count
	}
	
	func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
		let identifier = NSUserInterfaceItemIdentifier("column")
		let root = columns[indexPath.item]
		let item = collectionView.makeItem(withIdentifier: identifier, for: indexPath) as! ColumnViewController
		item.configure(for: root, with: storage)
		return item
	}
}

// MARK: - NSCollectionViewDelegate
extension ColumnsViewController: NSCollectionViewDelegate { }

// MARK: - ColumnsUnitView
extension ColumnsViewController: ColumnsUnitView {

	func display(state: ColumnsViewState) {
		placeholderView?.removeFromSuperview()
		switch state {
		case let .placeholder(model):
			placeholderView = NSHostingView(rootView: PlaceholderView(model: model))
			placeholderView?.pin(edges: .all, to: view)
			columns = []
			collectionView.reloadData()
		case let .columns(ids):
			display(ids)
		}
	}

	func display(_ columns: [UUID]) {

		guard let (removed, inserted) = calculateAnimation(for: columns) else {
			return
		}

		NSAnimationContext.runAnimationGroup { context in
			context.allowsImplicitAnimation = true

			if removed.count == 1, inserted.count == 1, removed.first == inserted.first,
			   let atIndex = removed.first?.source, let toIndex = inserted.first?.destination {
				collectionView.animator().moveItem(at: atIndex, to: toIndex)
				return
			}

			collectionView.performBatchUpdates {
				collectionView.animator().deleteItems(at: Set(removed.compactMap(\.source)))
				collectionView.animator().insertItems(at: Set(inserted.compactMap(\.destination)))
			}
		}
	}
}

// MARK: - Helpers
private extension ColumnsViewController {

	func calculateAnimation(for columns: [UUID]) -> (Set<Operation>, Set<Operation>)? {
		guard self.columns != columns else {
			return nil
		}

		let diff = columns.difference(from: self.columns).inferringMoves()

		let removed = diff.compactMap { change -> Operation? in
			guard case let .remove(offset, _, destination) = change else {
				return nil
			}
			return Operation(source: offset, destination: destination)
		}

		let inserted = diff.compactMap { change -> Operation? in
			guard case let .insert(offset, _, source) = change else {
				return nil
			}
			return Operation(source: source, destination: offset)
		}

		self.columns = columns

		return (Set(removed), Set(inserted))
	}
}

// MARK: - Nested data structs
extension ColumnsViewController {

	struct Operation: Hashable {

		var source: IndexPath?
		var destination: IndexPath?

		// MARK: - Initialization

		init(source: Int, destination: Int? = nil) {
			self.source = IndexPath(item: source, section: 0)
			self.destination = if let destination {
				IndexPath(item: destination, section: 0)
			} else {
				nil
			}
		}

		init(source: Int? = nil, destination: Int) {
			self.destination = IndexPath(item: destination, section: 0)
			self.source = if let source {
				IndexPath(item: source, section: 0)
			} else {
				nil
			}
		}
	}
}

//
//  ColumnsViewController.swift
//  Nested List
//
//  Created by Anton Cherkasov on 14.08.2025.
//

import AppKit
import DesignSystem

protocol ColumnsViewOutput: ViewDelegate {
	func handleNewColumnClick()
}

protocol ColumnsUnitView: AnyObject {
	func display(_ columns: [UUID])
}

class ColumnsViewController: NSViewController {

	private var columns: [UUID] = []

	// MARK: - DI

	var output: ColumnsViewOutput?

	let columnsFactory: ColumnsFactory

	// MARK: - UI

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

		view.dataSource = self
		view.delegate = self
		return view
	}()

	// MARK: - Initialization

	init(columnsFactory: ColumnsFactory, configure: (ColumnsViewController) -> Void) {
		self.columnsFactory = columnsFactory
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
		let root = columns[indexPath.item]
		return columnsFactory.build(for: root)
	}
}

// MARK: - NSCollectionViewDelegate
extension ColumnsViewController: NSCollectionViewDelegate { }

// MARK: - ColumnsUnitView
extension ColumnsViewController: ColumnsUnitView {

	func display(_ columns: [UUID]) {

		guard let (removed, inserted) = calculateAnimation(for: columns) else {
			return
		}

		NSAnimationContext.runAnimationGroup { context in
			context.allowsImplicitAnimation = true
			collectionView.animator().deleteItems(at: removed)
			collectionView.animator().insertItems(at: inserted)
		}
	}
}

// MARK: - Helpers
private extension ColumnsViewController {

	func calculateAnimation(for columns: [UUID]) -> (Set<IndexPath>, Set<IndexPath>)? {
		guard self.columns != columns else {
			return nil
		}

		let diff = columns.difference(from: self.columns)

		let removed = diff.compactMap { change -> IndexPath? in
			guard case let .remove(offset, _, _) = change else {
				return nil
			}
			return .init(item: offset, section: 0)
		}

		let inserted = diff.compactMap { change -> IndexPath? in
			guard case let .insert(offset, _, _) = change else {
				return nil
			}
			return .init(item: offset, section: 0)
		}

		self.columns = columns

		return (Set(removed), Set(inserted))
	}
}

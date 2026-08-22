//
//  ColumnsViewController.swift
//  macOS
//

import AppKit
import SwiftUI
import CoreModule
import DesignSystem
import CorePresentation

@MainActor
protocol ColumnsViewOutput: ViewDelegate {
	func handleNewColumnClick()
}

@MainActor
protocol ColumnsUnitView: AnyObject {
	func display(state: ColumnsViewState, completionHandler: @escaping () -> Void)
	func scroll(to id: UUID)
}

/// The Columns view controller.
class ColumnsViewController: NSViewController {

	private var columns: [UUID] = []

	private let storage: DocumentStorage<DocumentContent>

	private let factory: ColumnsFactory

	private let localization: any ColumnsLocalizationProtocol = ColumnsLocalization()

	private var placeholderView: NSView?

	var output: (any ColumnsViewOutput)?

	lazy var toolbar: NSToolbar = {
		let view = NSToolbar()
		view.displayMode = .iconOnly
		view.delegate = self
		return view
	}()

	lazy var scrollView: NSScrollView = {
		let view = NSScrollView()
		view.borderType = .noBorder
		view.hasHorizontalScroller = true
		view.autohidesScrollers = true
		view.hasVerticalScroller = false
		view.automaticallyAdjustsContentInsets = false
		view.contentInsets = .init()
		return view
	}()

	lazy var collectionView: NSCollectionView = {
		let view = NSCollectionView()
		view.backgroundColors = [.clear]
		return view
	}()

	// MARK: - Initialization

	init(storage: DocumentStorage<DocumentContent>, configure: (ColumnsViewController) -> Void) {
		self.storage = storage
		self.factory = ColumnsFactory(storage: storage)
		super.init(nibName: nil, bundle: nil)
		configure(self)
	}

	@available(*, unavailable, message: "Use init(storage:configure:)")
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

		collectionView.register(ColumnViewController.self, forItemWithIdentifier: .column)
		collectionView.dataSource = self
		collectionView.delegate = self

		output?.viewDidChange(state: .didLoad)
	}

	override func viewWillAppear() {
		super.viewWillAppear()
		output?.viewDidChange(state: .willAppear)
	}

	override func viewDidAppear() {
		super.viewDidAppear()
		configureToolbarIfNeeded()
	}
}

// MARK: - ColumnsUnitView
extension ColumnsViewController: ColumnsUnitView {

	func scroll(to id: UUID) {
		guard let index = columns.firstIndex(of: id) else {
			return
		}
		let indexPath = IndexPath(item: index, section: 0)
		NSAnimationContext.runAnimationGroup { context in
			context.allowsImplicitAnimation = true
			collectionView.animator().scrollToItems(at: .init([indexPath]), scrollPosition: .trailingEdge)
		}
	}

	func display(state: ColumnsViewState, completionHandler: @escaping () -> Void) {
		placeholderView?.removeFromSuperview()
		placeholderView = nil

		switch state {
		case let .placeholder(model):
			let hostingView = NSHostingView(rootView: PlaceholderView(model: model))
			hostingView.setAccessibilityIdentifier("columns-placeholder")
			hostingView.setAccessibilityRole(.group)
			hostingView.pin(edges: .all, to: view)
			placeholderView = hostingView
			columns = []
			collectionView.reloadData()
			completionHandler()
		case let .columns(ids):
			display(ids, completionHandler: completionHandler)
		}
	}
}

// MARK: - DocumentToolbarSupportable
extension ColumnsViewController: DocumentToolbarSupportable {

	func newItem(_ sender: Any) {
		output?.handleNewColumnClick()
	}
}

// MARK: - NSToolbarDelegate
extension ColumnsViewController: NSToolbarDelegate {

	func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
		return [.space, .newColumn]
	}

	func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
		return [.space, .newColumn]
	}

	func toolbar(
		_ toolbar: NSToolbar,
		itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier,
		willBeInsertedIntoToolbar flag: Bool
	) -> NSToolbarItem? {

		let item = NSToolbarItem(itemIdentifier: itemIdentifier)
		item.visibilityPriority = .high

		switch itemIdentifier {
		case .newColumn:
			let image = NSImage(systemSymbolName: "plus", accessibilityDescription: nil)!
			let button = NSButton(image: image, target: self, action: #selector(DocumentToolbarSupportable.newItem(_:)))
			button.bezelStyle = .toolbar
			button.imagePosition = .imageOnly
			button.sendAction(on: .leftMouseDown)

			item.label = localization.newItemToolbarItemLabel
			item.view = button
		default:
			break
		}

		return item
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

	func collectionView(
		_ collectionView: NSCollectionView,
		itemForRepresentedObjectAt indexPath: IndexPath
	) -> NSCollectionViewItem {
		let root = columns[indexPath.item]
		let item = collectionView.makeItem(withIdentifier: .column, for: indexPath) as? ColumnViewController
		guard let item else {
			return factory.build(for: root)
		}
		item.configure(for: root, with: storage)
		return item
	}
}

// MARK: - NSCollectionViewDelegate
extension ColumnsViewController: NSCollectionViewDelegate { }

// MARK: - Private Helpers
private extension ColumnsViewController {

	func configureUserInterface() {
		collectionView.frame = scrollView.contentView.bounds
		scrollView.documentView = collectionView
	}

	func configureLayout() {
		collectionView.collectionViewLayout = ColumnsLayout()
	}

	func configureConstraints() {
		scrollView.translatesAutoresizingMaskIntoConstraints = false

		if !view.subviews.contains(where: { $0 == scrollView }) {
			view.addSubview(scrollView)
		}

		NSLayoutConstraint.activate(
			[
				scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
				scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
				scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
				scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
			]
		)
	}

	func configureToolbarIfNeeded() {
		guard let window = view.window, window.toolbar == nil else {
			return
		}
		window.toolbar = toolbar
	}

	func display(_ columns: [UUID], completionHandler: @escaping () -> Void) {
		guard let (removed, inserted) = calculateAnimation(for: columns) else {
			completionHandler()
			return
		}

		NSAnimationContext.runAnimationGroup { context in
			context.allowsImplicitAnimation = true

			if removed.count == 1,
			   inserted.count == 1,
			   removed.first == inserted.first,
			   let atIndex = removed.first?.source,
			   let toIndex = inserted.first?.destination {
				collectionView.animator().moveItem(at: atIndex, to: toIndex)
				completionHandler()
				return
			}

			collectionView.performBatchUpdates {
				collectionView.animator().deleteItems(at: Set(removed.compactMap(\.source)))
				collectionView.animator().insertItems(at: Set(inserted.compactMap(\.destination)))
			} completionHandler: { finished in
				guard finished else {
					return
				}
				completionHandler()
			}
		}
	}

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

// MARK: - Nested Data Structs
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

// MARK: - Constants
private extension NSUserInterfaceItemIdentifier {
	static let column = NSUserInterfaceItemIdentifier("column")
}

private extension NSToolbarItem.Identifier {
	static let newColumn = NSToolbarItem.Identifier("new-column-toolbar-item")
}

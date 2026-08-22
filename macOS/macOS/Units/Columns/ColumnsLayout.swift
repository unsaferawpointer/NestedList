//
//  ColumnsLayout.swift
//  Nested List
//
//  Created by Anton Cherkasov on 21.08.2026.
//

import AppKit

final class ColumnsLayout: NSCollectionViewFlowLayout {

	// MARK: - Public Properties

	var minimumColumnWidth: CGFloat = 320 {
		didSet {
			invalidateLayout()
		}
	}

	var columnSpacing: CGFloat = 12 {
		didSet {
			invalidateLayout()
		}
	}

	var margins = NSEdgeInsets(top: 12, left: 12, bottom: 12, right: 12) {
		didSet {
			invalidateLayout()
		}
	}

	private var cachedAttributes:
	[IndexPath: NSCollectionViewLayoutAttributes] = [:]

	private var cachedContentSize: NSSize = .zero

	// MARK: - Initialization

	override init() {
		super.init()
		scrollDirection = .horizontal
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		scrollDirection = .horizontal
	}

	// MARK: - Life cycle

	override func prepare() {
		super.prepare()
		calculateLayout()
	}

	override var collectionViewContentSize: NSSize { cachedContentSize }

	override func layoutAttributesForElements(in rect: NSRect) -> [NSCollectionViewLayoutAttributes] {
		cachedAttributes.values.filter {
			$0.frame.intersects(rect)
		}
	}

	override func layoutAttributesForItem(at indexPath: IndexPath) -> NSCollectionViewLayoutAttributes? {
		cachedAttributes[indexPath]
	}

	override func shouldInvalidateLayout(forBoundsChange newBounds: NSRect) -> Bool {
		true
	}
}

// MARK: - Helpers
private extension ColumnsLayout {

	func calculateLayout() {
		guard let collectionView, let scrollView = collectionView.enclosingScrollView else {
			return
		}

		cachedAttributes.removeAll()

		guard collectionView.numberOfSections <= 1 else {
			fatalError("Unsupported: multiple sections")
		}

		let columnCount = collectionView.numberOfItems(inSection: 0)
		let clipSize = scrollView.contentView.bounds.size
		let viewportSize = NSSize(width: clipSize.width, height: max(0, clipSize.height))

		guard columnCount > 0 else {
			cachedContentSize = viewportSize
			return
		}

		// MARK: - Horizontal

		let totalSpacing = CGFloat(max(0, columnCount - 1)) * columnSpacing
		let horizontalInsets = margins.left + margins.right

		let minimumContentWidth = horizontalInsets + totalSpacing + CGFloat(columnCount) * minimumColumnWidth

		let columnWidth: CGFloat = {
			if viewportSize.width >= minimumContentWidth {
				let availableWidth = viewportSize.width - horizontalInsets - totalSpacing
				return availableWidth / CGFloat(columnCount)
			} else {
				return minimumColumnWidth
			}
		}()

		// MARK: - Vertical

		let columnHeight = max(0, viewportSize.height - margins.top - margins.bottom)
		let y: CGFloat = collectionView.isFlipped ? margins.top : margins.bottom

		// MARK: - Columns

		setupColumns(count: columnCount, y: y, width: columnWidth, height: columnHeight)

		// MARK: - Content size

		let contentWidth = margins.left + CGFloat(columnCount) * columnWidth + totalSpacing + margins.right

		cachedContentSize = NSSize(
			width: max(viewportSize.width, contentWidth),
			height: viewportSize.height
		)
	}

	func setupColumns(count: Int, y: CGFloat, width: CGFloat, height: CGFloat) {
		for column in 0..<count {

			let indexPath = IndexPath(item: column, section: 0)
			let attributes = NSCollectionViewLayoutAttributes(forItemWith: indexPath)
			let x = margins.left + CGFloat(column) * (width + columnSpacing)

			attributes.frame = NSRect(x: x, y: y, width: width, height: height)

			cachedAttributes[indexPath] = attributes
		}
	}
}

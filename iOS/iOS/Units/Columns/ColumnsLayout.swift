//
//  ColumnsLayout.swift
//  iOS
//

import UIKit

final class ColumnsLayout: UICollectionViewFlowLayout {

	var minimumColumnWidth: CGFloat = 320 {
		didSet { invalidateLayout() }
	}

	var columnSpacing: CGFloat = 12 {
		didSet { invalidateLayout() }
	}

	var margins = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12) {
		didSet { invalidateLayout() }
	}

	private var cachedAttributes: [IndexPath: UICollectionViewLayoutAttributes] = [:]
	private var cachedContentSize: CGSize = .zero

	// MARK: - Initialization

	override init() {
		super.init()
		scrollDirection = .horizontal
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		scrollDirection = .horizontal
	}

	// MARK: - Life Cycle

	override func prepare() {
		super.prepare()
		calculateLayout()
	}

	override var collectionViewContentSize: CGSize {
		cachedContentSize
	}

	override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
		cachedAttributes.values.filter {
			$0.frame.intersects(rect)
		}
	}

	override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
		cachedAttributes[indexPath]
	}

	override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
		true
	}
}

// MARK: - Helpers
private extension ColumnsLayout {

	func calculateLayout() {
		guard let collectionView else {
			return
		}

		cachedAttributes.removeAll(keepingCapacity: true)

		let contentInsets = collectionView.adjustedContentInset
		let viewportSize = CGSize(
			width: max(0, collectionView.bounds.width - contentInsets.left - contentInsets.right),
			height: max(0, collectionView.bounds.height - contentInsets.top - contentInsets.bottom)
		)

		let columnCount = collectionView.numberOfItems(inSection: 0)
		guard columnCount > 0 else {
			cachedContentSize = viewportSize
			return
		}

		// MARK: - Horizontal

		let totalSpacing = CGFloat(max(0, columnCount - 1)) * columnSpacing
		let horizontalMargins = margins.left + margins.right
		let minimumContentWidth = horizontalMargins + totalSpacing + CGFloat(columnCount) * minimumColumnWidth
		let isCompact = collectionView.traitCollection.horizontalSizeClass == .compact
		let fitsAllColumns = viewportSize.width >= minimumContentWidth

		let columnWidth: CGFloat = {
			if isCompact {
				return max(0, viewportSize.width - horizontalMargins)
			}

			guard fitsAllColumns else {
				return minimumColumnWidth
			}

			let availableWidth = viewportSize.width - horizontalMargins - totalSpacing
			return availableWidth / CGFloat(columnCount)
		}()

		// MARK: - Vertical

		let columnHeight = max(0, viewportSize.height - margins.top - margins.bottom)

		// MARK: - Columns

		setupColumns(
			count: columnCount,
			width: columnWidth,
			height: columnHeight,
			step: isCompact ? collectionView.bounds.width : columnWidth + columnSpacing
		)

		// MARK: - Content size

		let contentWidth: CGFloat = if isCompact {
			CGFloat(columnCount) * collectionView.bounds.width - contentInsets.left - contentInsets.right
		} else {
			horizontalMargins + CGFloat(columnCount) * columnWidth + totalSpacing
		}
		cachedContentSize = CGSize(
			width: max(viewportSize.width, contentWidth),
			height: viewportSize.height
		)
	}

	func setupColumns(count: Int, width: CGFloat, height: CGFloat, step: CGFloat) {
		for column in 0..<count {
			let indexPath = IndexPath(item: column, section: 0)
			let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
			let x = margins.left + CGFloat(column) * step
			let y = margins.top

			attributes.frame = CGRect(x: x, y: y, width: width, height: height)
			cachedAttributes[indexPath] = attributes
		}
	}
}

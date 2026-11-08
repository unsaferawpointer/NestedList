import UIKit

final class PathView: UIView {

	var didSelectItem: ((UUID?) -> Void)?

	private lazy var collectionView: UICollectionView = {

		let layout = UICollectionViewFlowLayout()
		layout.scrollDirection = .horizontal
		layout.estimatedItemSize = CGSize(width: 64, height: 44)
		layout.minimumLineSpacing = 0
		layout.minimumInteritemSpacing = 8
		layout.sectionInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)

		let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
		view.backgroundColor = .clear
		view.showsHorizontalScrollIndicator = false
		view.contentInsetAdjustmentBehavior = .never
		view.dataSource = self
		view.delegate = self
		view.register(
			PathComponentCell.self,
			forCellWithReuseIdentifier: PathComponentCell.reuseIdentifier
		)
		view.register(
			PathSeparatorCell.self,
			forCellWithReuseIdentifier: PathSeparatorCell.reuseIdentifier
		)
		return view
	}()

	private var items: [CellKind] = []
	private var needsScrollToEnd = false
	private var previousSize: CGSize = .zero

	override init(frame: CGRect) {
		super.init(frame: frame)
		configureLayout()
		configureAccessibility()
		configureUserInterface()
		observeTraitChanges()
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override var intrinsicContentSize: CGSize {
		CGSize(width: UIView.noIntrinsicMetric, height: max(44, ceil(componentFont.lineHeight) + 10))
	}

	override func layoutSubviews() {
		super.layoutSubviews()
		guard bounds.width > 0, bounds.height > 0,
			  needsScrollToEnd || previousSize != bounds.size else {
			return
		}
		previousSize = bounds.size
		needsScrollToEnd = false
		let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
		if layout.estimatedItemSize.height != collectionView.bounds.height {
			layout.estimatedItemSize = CGSize(width: 64, height: collectionView.bounds.height)
		}
		guard !items.isEmpty else { return }
		collectionView.scrollToItem(
			at: IndexPath(item: items.count - 1, section: 0),
			at: .right, animated: false
		)
		collectionView.layoutIfNeeded()
		let offset = max(0, collectionView.contentSize.width - collectionView.bounds.width)
		if collectionView.contentOffset.x != offset {
			collectionView.setContentOffset(CGPoint(x: offset, y: 0), animated: false)
		}
	}

}

// MARK: - Public Interface
extension PathView {

	var isEmpty: Bool {
		items.isEmpty
	}

	func display(_ items: [PathItem]) {
		let cells = items.map {
			[CellKind.item(value: $0)]
		}.joined(separator: [CellKind.separator])
		.compactMap { $0 }
		guard self.items != cells else { return }
		self.items = cells

		collectionView.reloadData()
		isHidden = items.isEmpty
		needsScrollToEnd = true
		setNeedsLayout()
	}
}

// MARK: - UICollectionViewDataSource
extension PathView: UICollectionViewDataSource {

	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		items.count
	}

	func collectionView(
		_ collectionView: UICollectionView,
		cellForItemAt indexPath: IndexPath
	) -> UICollectionViewCell {
		let element = items[indexPath.item]
		switch element {
		case .separator:
			return collectionView.dequeueReusableCell(
				withReuseIdentifier: PathSeparatorCell.reuseIdentifier,
				for: indexPath
			)
		case let .item(value):
			let cell = collectionView.dequeueReusableCell(
				withReuseIdentifier: PathComponentCell.reuseIdentifier,
				for: indexPath
			) as! PathComponentCell
			let isLast = indexPath.item == items.count - 1
			cell.display(value.text, font: componentFont, isSelected: isLast)
			return cell
		}
	}
}

// MARK: - UICollectionViewDelegate
extension PathView: UICollectionViewDelegate {

	func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
		guard case .item = items[indexPath.item] else {
			return false
		}
		return true
	}

	func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
		guard case .item = items[indexPath.item] else {
			return false
		}
		return true
	}

	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		collectionView.deselectItem(at: indexPath, animated: false)
		switch items[indexPath.row] {
		case .separator:
			break
		case let .item(value):
			didSelectItem?(value.id)
		}
	}

}

extension PathView {

	enum CellKind: Equatable {
		case separator
		case item(value: PathItem)
	}
}

// MARK: - Private
private extension PathView {

	var componentFont: UIFont {
		.preferredFont(
			forTextStyle: .body,
			compatibleWith: traitCollection
		)
	}

	func configureUserInterface() {
		backgroundColor = .clear
		isHidden = true
	}

	func configureAccessibility() {
		accessibilityIdentifier = "path-control"
	}

	func configureLayout() {
		setContentHuggingPriority(.required, for: .vertical)
		setContentCompressionResistancePriority(.required, for: .vertical)

		directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 12)
		addSubview(collectionView)
		collectionView.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			collectionView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
			collectionView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
			collectionView.topAnchor.constraint(equalTo: topAnchor),
			collectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
		])
	}

	func observeTraitChanges() {
		registerForTraitChanges([UITraitPreferredContentSizeCategory.self]) { (view: PathView, _: UITraitCollection) in
			view.collectionView.reloadData()
			view.invalidateIntrinsicContentSize()
			view.needsScrollToEnd = true
			view.setNeedsLayout()
		}
	}
}

//
//  ColumnsViewController.swift
//  iOS
//

import UIKit
import DesignSystem

@MainActor
protocol ColumnsView: AnyObject {
	func display(_ columns: [UUID])
}

@MainActor
final class ColumnsViewController: UIViewController {

	// MARK: - DI

	var output: (any ColumnsViewOutput)?

	// MARK: - Data

	private var columns: [UUID] = []

	// MARK: - UI

	private lazy var collectionView: UICollectionView = {
		let view = UICollectionView(frame: .zero, collectionViewLayout: ColumnsLayout())
		view.backgroundColor = .systemBackground
		view.contentInsetAdjustmentBehavior = .always
		view.alwaysBounceHorizontal = true
		view.alwaysBounceVertical = false
		view.isPagingEnabled = true
		view.showsHorizontalScrollIndicator = true
		view.showsVerticalScrollIndicator = false
		view.dataSource = self
		view.register(ColumnsCell.self, forCellWithReuseIdentifier: ColumnsCell.reuseIdentifier)
		return view
	}()

	// MARK: - Initialization

	init(configure: (ColumnsViewController) -> Void) {
		super.init(nibName: nil, bundle: nil)
		configure(self)
	}

	@available(*, unavailable, message: "Use init(configure:)")
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - UIViewController life-cycle

	override func loadView() {
		view = UIView()
		collectionView.pin(edges: .all, to: view)
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		updatePagingBehavior()
		output?.viewDidChange(state: .didLoad)
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		output?.viewDidChange(state: .willAppear)
	}

	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)

		guard
			previousTraitCollection?.horizontalSizeClass != traitCollection.horizontalSizeClass ||
			previousTraitCollection?.verticalSizeClass != traitCollection.verticalSizeClass
		else {
			return
		}

		guard isViewLoaded else {
			return
		}

		updatePagingBehavior()
		collectionView.collectionViewLayout.invalidateLayout()
	}
}

// MARK: - Private Methods
private extension ColumnsViewController {

	func updatePagingBehavior() {
		collectionView.isPagingEnabled = traitCollection.horizontalSizeClass == .compact
	}
}

// MARK: - ColumnsView
extension ColumnsViewController: ColumnsView {

	func display(_ columns: [UUID]) {
		self.columns = columns
		collectionView.reloadData()
	}
}

// MARK: - UICollectionViewDataSource
extension ColumnsViewController: UICollectionViewDataSource {

	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		columns.count
	}

	func collectionView(
		_ collectionView: UICollectionView,
		cellForItemAt indexPath: IndexPath
	) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(
			withReuseIdentifier: ColumnsCell.reuseIdentifier,
			for: indexPath
		)
		guard let cell = cell as? ColumnsCell else {
			return cell
		}
		cell.configure(with: columns[indexPath.item])
		return cell
	}
}

// MARK: - ColumnsModel
private extension ColumnsViewController {

	final class ColumnsCell: UICollectionViewCell {

		static let reuseIdentifier = "ColumnsCell"

		private let titleLabel: UILabel = {
			let label = UILabel()
			label.font = .preferredFont(forTextStyle: .headline)
			label.numberOfLines = 0
			return label
		}()

		override init(frame: CGRect) {
			super.init(frame: frame)
			backgroundColor = .secondarySystemBackground
			layer.cornerRadius = 12
			contentView.addSubview(titleLabel)
			titleLabel.pin(edges: [.leading, .top, .trailing], to: contentView, with: 16)
		}

		@available(*, unavailable)
		required init?(coder: NSCoder) {
			fatalError("init(coder:) has not been implemented")
		}

		func configure(with column: UUID) {
			titleLabel.text = column.uuidString
		}
	}
}

// MARK: - ColumnsViewOutput
extension ColumnsViewController {

	func updateOutput(_ output: (any ColumnsViewOutput)?) {
		self.output = output
	}
}

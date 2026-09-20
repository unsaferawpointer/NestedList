//
//  ColumnCell.swift
//  iOS
//

import UIKit

@MainActor
protocol ColumnView: AnyObject {
	func display()
}

@MainActor
final class ColumnCell: UICollectionViewCell {

	static let reuseIdentifier = "ColumnCell"

	private weak var embeddedViewController: UIViewController?

	var output: (any ColumnViewOutput)?

	// MARK: - Initialization

	override init(frame: CGRect) {
		super.init(frame: frame)
		backgroundColor = .secondarySystemBackground
		layer.cornerRadius = 12
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - UIViewController Container

	func embed(_ viewController: UIViewController, in parent: UIViewController) {
		removeEmbeddedViewController()

		parent.addChild(viewController)
		contentView.addSubview(viewController.view)
		viewController.view.pin(edges: .all, to: contentView)
		viewController.didMove(toParent: parent)
		embeddedViewController = viewController
	}

	override func prepareForReuse() {
		removeEmbeddedViewController()
		output = nil
		super.prepareForReuse()
	}
}

// MARK: - ColumnView
extension ColumnCell: ColumnView {

	func display() { }
}

// MARK: - Configuration
extension ColumnCell {

	func configure() {
		output?.viewDidChange(state: .didLoad)
	}
}

// MARK: - Private Methods
private extension ColumnCell {

	func removeEmbeddedViewController() {
		guard let viewController = embeddedViewController else {
			return
		}
		viewController.willMove(toParent: nil)
		viewController.view.removeFromSuperview()
		viewController.removeFromParent()
		embeddedViewController = nil
	}
}

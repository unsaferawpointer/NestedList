import UIKit

final class PathSeparatorCell: PathCell {

	static let reuseIdentifier = "path-separator"

	// MARK: - Interface

	private lazy var imageView: UIImageView = {
		let view = UIImageView()
		view.tintColor = .tertiaryLabel
		view.contentMode = .center
		view.image = UIImage(
			systemName: "chevron.forward",
			withConfiguration: UIImage.SymbolConfiguration(textStyle: .caption2, scale: .small)
		)
		view.adjustsImageSizeForAccessibilityContentSizeCategory = true
		return view
	}()

	// MARK: - Initialization

	override init(frame: CGRect) {
		super.init(frame: frame)
		configureLayout()
		configureAccessibility()
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

// MARK: - Private
private extension PathSeparatorCell {

	func configureAccessibility() {
		isAccessibilityElement = false
		accessibilityElementsHidden = true
	}

	func configureLayout() {
		imageView.translatesAutoresizingMaskIntoConstraints = false
		contentView.addSubview(imageView)
		NSLayoutConstraint.activate([
			imageView.leadingAnchor.constraint(
				equalToSystemSpacingAfter: contentView.leadingAnchor,
				multiplier: 0.5
			),
			contentView.trailingAnchor.constraint(
				equalToSystemSpacingAfter: imageView.trailingAnchor,
				multiplier: 0.5
			),
			imageView.centerYAnchor.constraint(
				equalTo: contentView.centerYAnchor
			)
		])
	}
}

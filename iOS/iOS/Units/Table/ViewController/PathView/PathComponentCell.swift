import UIKit

final class PathComponentCell: PathCell {

	static let reuseIdentifier = "path-component"

	private let titleLabel = UILabel()

	override var isHighlighted: Bool {
		didSet {
			contentView.alpha = isHighlighted ? 0.5 : 1
		}
	}

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

// MARK: - Public Interface
extension PathComponentCell {

	func display(_ text: String, font: UIFont, isSelected: Bool) {
		titleLabel.text = text
		titleLabel.font = font
		titleLabel.textColor = isSelected ? .label : .secondaryLabel
		accessibilityLabel = text
		accessibilityTraits = isSelected ? [.button, .selected] : [.button]
	}
}

// MARK: - Private
private extension PathComponentCell {

	func configureAccessibility() {
		isAccessibilityElement = true
		titleLabel.isAccessibilityElement = false
	}

	func configureLayout() {
		titleLabel.adjustsFontForContentSizeCategory = true
		titleLabel.translatesAutoresizingMaskIntoConstraints = false
		contentView.addSubview(titleLabel)
		NSLayoutConstraint.activate([
			titleLabel.leadingAnchor.constraint(
				equalToSystemSpacingAfter: contentView.leadingAnchor,
				multiplier: 0.5
			),
			contentView.trailingAnchor.constraint(
				equalToSystemSpacingAfter: titleLabel.trailingAnchor,
				multiplier: 0.5
			),
			titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
			titleLabel.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor, constant: 5),
			titleLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -5)
		])
	}
}

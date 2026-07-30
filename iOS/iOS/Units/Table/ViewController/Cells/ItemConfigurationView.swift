//
//  ItemConfigurationView.swift
//  iOS
//
//  Created by Anton Cherkasov on 30.07.2026.
//

import UIKit
import DesignSystem
import CoreModule

/// Hand-built content view for ``ItemConfiguration``.
///
/// Reproduces the layout of `UIListContentConfiguration.cell()`: a leading icon
/// followed by a title and an optional subtitle.
final class ItemConfigurationView: UIView {

	// MARK: - UI - Properties

	private lazy var iconView: UIImageView = {
		let view = UIImageView()
		view.contentMode = .scaleAspectFit
		view.setContentHuggingPriority(.required, for: .horizontal)
		view.setContentCompressionResistancePriority(.required, for: .horizontal)
		return view
	}()

	/// Fixed width of the icon column, so the text leading is identical for every row
	/// regardless of the icon's intrinsic width.
	private static let iconColumnWidth = UIFontMetrics.default.scaledValue(for: 28)

	private lazy var titleLabel: UILabel = {
		let label = UILabel()
		label.numberOfLines = 1
		label.adjustsFontForContentSizeCategory = true
		return label
	}()

	private lazy var subtitleLabel: UILabel = {
		let label = UILabel()
		label.numberOfLines = 1
		label.adjustsFontForContentSizeCategory = true
		return label
	}()

	private lazy var textStack: UIStackView = {
		let stack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
		stack.axis = .vertical
		stack.alignment = .fill
		stack.spacing = 2
		return stack
	}()

	private lazy var contentStack: UIStackView = {
		let stack = UIStackView(arrangedSubviews: [iconView, textStack])
		stack.axis = .horizontal
		stack.alignment = .center
		stack.spacing = 12
		return stack
	}()

	private lazy var trailingArrow: UIImageView = {
		let view = UIImageView()
		view.image = UIImage(systemName: "chevron.right")?
			.withConfiguration(UIImage.SymbolConfiguration(scale: .small))
		view.contentMode = .center
		view.tintColor = .secondaryLabel
		view.setContentHuggingPriority(.defaultHigh, for: .horizontal)
		view.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
		return view
	}()

	// MARK: - Internal State

	private var _configuration: ItemConfiguration

	// MARK: - Initialization

	init(configuration: ItemConfiguration) {
		self._configuration = configuration
		super.init(frame: .zero)
		configureView()
		apply(configuration)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

// MARK: - UIContentView
extension ItemConfigurationView: UIContentView {

	var configuration: any UIContentConfiguration {
		get {
			return _configuration
		}
		set {
			guard let configuration = newValue as? ItemConfiguration else {
				return
			}
			apply(configuration)
		}
	}
}

// MARK: - Private interface
private extension ItemConfigurationView {

	func configureView() {
		backgroundColor = .clear
		directionalLayoutMargins = NSDirectionalEdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 16)

		[contentStack, trailingArrow].forEach {
			$0.translatesAutoresizingMaskIntoConstraints = false
			addSubview($0)
		}

		NSLayoutConstraint.activate([
			iconView.widthAnchor.constraint(equalToConstant: Self.iconColumnWidth),

			contentStack.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
			contentStack.trailingAnchor.constraint(equalTo: trailingArrow.leadingAnchor, constant: -4),
			contentStack.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor, constant: 8),
			contentStack.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor, constant: -8),

			trailingArrow.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
			trailingArrow.centerYAnchor.constraint(equalTo: centerYAnchor)
		])
	}

	func apply(_ configuration: ItemConfiguration) {
		_configuration = configuration

		iconView.image = makeImage(from: configuration)
		iconView.tintColor = configuration.icon?.appearence.tint

		trailingArrow.isHidden = !configuration.showsTrailingDisclosure

		let title = configuration.title
		titleLabel.font = .preferredFont(forTextStyle: title.style.value)
		titleLabel.attributedText = NSAttributedString(
			string: title.text,
			textColor: title.colorToken.value,
			strikethrough: title.strikethrough
		)

		if let subtitle = configuration.subtitle {
			subtitleLabel.isHidden = false
			subtitleLabel.font = .preferredFont(forTextStyle: subtitle.style.value)
			subtitleLabel.textColor = subtitle.colorToken.value
			subtitleLabel.text = subtitle.text
		} else {
			subtitleLabel.isHidden = true
			subtitleLabel.text = nil
		}
	}

	func makeImage(from configuration: ItemConfiguration) -> UIImage? {
		guard let icon = configuration.icon else {
			return nil
		}
		let symbolConfiguration = icon.appearence.configuration
		return icon.name?.uiImage
			.applyingSymbolConfiguration(symbolConfiguration)?
			.applyingSymbolConfiguration(.init(textStyle: configuration.title.style.value))?
			.applyingSymbolConfiguration(.init(scale: .medium))
	}
}

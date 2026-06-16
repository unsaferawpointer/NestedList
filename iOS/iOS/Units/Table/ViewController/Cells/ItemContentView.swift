//
//  ItemContentView.swift
//  iOS
//
//  Created by Anton Cherkasov on 04.06.2026.
//

import UIKit

final class ItemContentView<ID: Hashable>: UIView {

	// MARK: - UI - Properties

	lazy var disclosureArrow: UIImageView = {
		let view = UIImageView()
		view.image = UIImage(systemName: "chevron.right")?
			.withConfiguration(UIImage.SymbolConfiguration(scale: .small))
		view.contentMode = .center
		view.tintColor = .secondaryLabel
		view.setContentHuggingPriority(.defaultHigh, for: .horizontal)
		view.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
		return view
	}()

	lazy var listContentView: UIListContentView = {
		let view = UIListContentView(configuration: _configuration.content)
		view.backgroundColor = .clear
		return view
	}()

	lazy var trailingArrow: UIImageView = {
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

	private var _configuration: ItemContentConfiguration<ID>

	// MARK: - Constraints

	private var leadingConstraint: NSLayoutConstraint?

	init(configuration: ItemContentConfiguration<ID>) {
		_configuration = configuration
		super.init(frame: .zero)
		configureView()
		apply(configuration)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func layoutSubviews() {
		super.layoutSubviews()
		updateLayoutConstraints()
	}
}

// MARK: - UIContentView
extension ItemContentView: UIContentView {

	var configuration: any UIContentConfiguration {
		get {
			return _configuration
		}
		set {
			guard let configuration = newValue as? ItemContentConfiguration<ID> else {
				return
			}
			apply(configuration)
		}
	}
}

// MARK: - Private interface
private extension ItemContentView {

	func configureView() {
		preservesSuperviewLayoutMargins = true
		backgroundColor = .clear

		configureConstraints()
	}

	func configureConstraints() {
		[listContentView, disclosureArrow, trailingArrow].forEach {
			$0.translatesAutoresizingMaskIntoConstraints = false
			addSubview($0)
		}

		let listContentLeadingConstraint = disclosureArrow.leadingAnchor.constraint(equalTo: leadingAnchor)
		self.leadingConstraint = listContentLeadingConstraint

		NSLayoutConstraint.activate([
			listContentLeadingConstraint,
			disclosureArrow.trailingAnchor.constraint(equalTo: listContentView.leadingAnchor),
			disclosureArrow.centerYAnchor.constraint(equalTo: centerYAnchor),

			listContentView.topAnchor.constraint(equalTo: topAnchor),
			listContentView.trailingAnchor.constraint(equalTo: trailingArrow.leadingAnchor, constant: -4),
			listContentView.bottomAnchor.constraint(equalTo: bottomAnchor),

			trailingArrow.centerYAnchor.constraint(equalTo: centerYAnchor),
			trailingArrow.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
		])
	}

}

// MARK: - Helpers
private extension ItemContentView {

	func apply(_ configuration: ItemContentConfiguration<ID>) {
		let oldConfiguration = _configuration
		_configuration = configuration
		listContentView.configuration = configuration.content

		updateArrowVisibility()
		updateLayoutConstraints()

		guard oldConfiguration.row.isExpanded != configuration.row.isExpanded
		   && oldConfiguration.id == configuration.id else {
			updateArrowTransform(animated: false)
			return
		}

		updateArrowTransform(animated: true)
	}

	func updateArrowVisibility() {
		disclosureArrow.isHidden = _configuration.row.isLeaf
		trailingArrow.isHidden = !_configuration.showsTrailingDisclosure
	}

	func updateArrowTransform(animated: Bool) {
		let transform = _configuration.row.isExpanded
			? CGAffineTransform(rotationAngle: .pi / 2)
			: .identity

		if animated {
			UIView.animate(withDuration: 0.25) {
				self.disclosureArrow.transform = transform
			}
		} else {
			disclosureArrow.transform = transform
		}
	}

	func updateLayoutConstraints() {
		leadingConstraint?.constant = offset + 16
	}
}

// MARK: - Helpers
private extension ItemContentView {

	var level: Int { _configuration.row.level }

	var offset: CGFloat {
		guard level > 0 else {
			return 0
		}

		let isPad = UIDevice.current.userInterfaceIdiom == .pad
		let attenuation = isPad ? 0.1 : 0.4
		let interval = bounds.width - 240.0
		let offset = interval - exp(-attenuation * Double(level)) * interval

		return offset
	}
}

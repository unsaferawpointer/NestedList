//
//  ContainerView.swift
//  DesignSystem
//
//  Created by Anton Cherkasov on 29.07.2026.
//

#if canImport(UIKit)
import UIKit

protocol CellContent: Identifiable, UIContentConfiguration {
	associatedtype View: UIView & UIContentView
}

protocol ContentContainer: Identifiable {
	associatedtype Content: CellContent
	var value: Content { get }
}

final class ContainerView<C: CellContent>: UIView {

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

	lazy var contentView: any UIView & UIContentView = {
		let view = _configuration.makeContentView()
		view.backgroundColor = .clear
		return view
	}()

	// MARK: - Internal State

	private var _configuration: ContainerConfiguration<C>

	// MARK: - Constraints

	private var leadingConstraint: NSLayoutConstraint?

	init(configuration: ContainerConfiguration<C>) {
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
extension ContainerView: UIContentView {

	var configuration: any UIContentConfiguration {
		get {
			return _configuration
		}
		set {
			guard let configuration = newValue as? ContainerConfiguration<C> else {
				return
			}
			apply(configuration)
		}
	}
}

// MARK: - Private interface
private extension ContainerView {

	func configureView() {
		preservesSuperviewLayoutMargins = true
		backgroundColor = .clear

		configureConstraints()
	}

	func configureConstraints() {
		[contentView, disclosureArrow].forEach {
			$0.translatesAutoresizingMaskIntoConstraints = false
			addSubview($0)
		}

		let listContentLeadingConstraint = disclosureArrow.leadingAnchor.constraint(equalTo: leadingAnchor)
		self.leadingConstraint = listContentLeadingConstraint

		NSLayoutConstraint.activate([
			listContentLeadingConstraint,
			disclosureArrow.trailingAnchor.constraint(equalTo: contentView.leadingAnchor),
			disclosureArrow.centerYAnchor.constraint(equalTo: centerYAnchor),

			contentView.topAnchor.constraint(equalTo: topAnchor),
			contentView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
			contentView.bottomAnchor.constraint(equalTo: bottomAnchor)
		])
	}

}

// MARK: - Helpers
private extension ContainerView {

	func apply(_ configuration: ContainerConfiguration<C>) {
		let oldConfiguration = _configuration
		_configuration = configuration
		contentView.configuration = configuration.content

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
private extension ContainerView {

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
#endif

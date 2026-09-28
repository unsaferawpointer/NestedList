//
//  CompositeIcon.swift
//  DesignSystem
//

import Foundation

#if os(iOS)

import UIKit

public final class CompositeIcon: UIView {

	// MARK: - UI

	private lazy var iconView: UIImageView = {
		let view = UIImageView()
		view.contentMode = .center
		return view
	}()

	private lazy var badgeIconView: UIImageView = {
		let view = UIImageView()
		view.contentMode = .scaleAspectFit
		return view
	}()

	private lazy var badgeBackgroundView: UIView = {
		let view = UIView()
		view.backgroundColor = .systemBackground
		view.layer.cornerCurve = .circular
		view.layer.masksToBounds = true
		view.addSubview(badgeIconView)
		return view
	}()

	// MARK: - State

	public var iconConfiguration: IconConfiguration? {
		didSet {
			updateForCurrentTraits()
		}
	}
	public var badgeConfiguration: IconConfiguration? {
		didSet {
			updateForCurrentTraits()
		}
	}
	public var textStyle: TextStyle = .body {
		didSet {
			updateForCurrentTraits()
		}
	}
	private var contentSizeCategoryObserver: NSObjectProtocol?

	private let iconBaseSide: CGFloat = 28
	private let badgeSideRatio: CGFloat = 12 / 28
	private let badgePaddingRatio: CGFloat = 2 / 28
	private let referenceFontPointSize = UIFont.preferredFont(forTextStyle: .body).pointSize

	// MARK: - Initialization

	public init() {
		super.init(frame: .zero)
		addSubviews()
		contentSizeCategoryObserver = NotificationCenter.default.addObserver(
			forName: UIContentSizeCategory.didChangeNotification,
			object: nil,
			queue: .main
		) { [weak self] _ in
			self?.updateForCurrentTraits()
		}
	}

	@available(*, unavailable, message: "Use init()")
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	deinit {
		if let contentSizeCategoryObserver {
			NotificationCenter.default.removeObserver(contentSizeCategoryObserver)
		}
	}
}

// MARK: - Layout

extension CompositeIcon {

	public override var intrinsicContentSize: CGSize {
		let badgeSide = semanticIconSide * badgeSideRatio
		return CGSize(
			width: scaled(iconBaseSide) + badgeSide,
			height: semanticIconSide + badgeSide
		)
	}

	public override func layoutSubviews() {
		super.layoutSubviews()
		layoutCompositeIcon()
	}
}

// MARK: - View hierarchy

private extension CompositeIcon {

	func addSubviews() {
		addSubview(iconView)
		addSubview(badgeBackgroundView)
		setContentHuggingPriority(.required, for: .horizontal)
		setContentCompressionResistancePriority(.required, for: .horizontal)
	}
}

// MARK: - Layout

private extension CompositeIcon {

	func layoutCompositeIcon() {
		let iconSide = semanticIconSide
		let badgeSide = iconSide * badgeSideRatio
		let iconFrame = CGRect(
			x: (bounds.width - iconSide) / 2,
			y: (bounds.height - iconSide) / 2,
			width: iconSide,
			height: iconSide
		)
		let badgeFrame = CGRect(
			x: iconFrame.minX - badgeSide / 2,
			y: iconFrame.maxY - badgeSide / 2,
			width: badgeSide,
			height: badgeSide
		)

		iconView.frame = iconFrame
		badgeBackgroundView.frame = badgeFrame

		let badgePadding = iconSide * badgePaddingRatio
		let badgeIconSide = badgeSide - badgePadding * 2
		badgeIconView.frame = CGRect(
			x: (badgeBackgroundView.bounds.width - badgeIconSide) / 2,
			y: (badgeBackgroundView.bounds.height - badgeIconSide) / 2,
			width: badgeIconSide,
			height: badgeIconSide
		)
	}
}

// MARK: - State updates

private extension CompositeIcon {

	func updateForCurrentTraits() {
		iconView.image = makeImage(configuration: iconConfiguration, scale: .medium)
		iconView.tintColor = iconConfiguration?.appearence.tint
		badgeIconView.image = makeImage(configuration: badgeConfiguration, scale: .small)
		badgeIconView.tintColor = badgeConfiguration?.appearence.tint
		badgeBackgroundView.isHidden = badgeConfiguration == nil
		badgeBackgroundView.layer.cornerRadius = semanticIconSide * badgeSideRatio / 2
		invalidateIntrinsicContentSize()
		setNeedsLayout()
	}
}

// MARK: - Helpers

private extension CompositeIcon {

	func scaled(_ value: CGFloat) -> CGFloat {
		let font = semanticFont
		return value * font.pointSize / referenceFontPointSize
	}

	var semanticFont: UIFont {
		UIFont.preferredFont(forTextStyle: textStyle.value, compatibleWith: traitCollection)
	}

	var semanticIconSide: CGFloat {
		semanticFont.lineHeight
	}

	func makeImage(
		configuration: IconConfiguration?,
		scale: UIImage.SymbolScale
	) -> UIImage? {
		guard let configuration else {
			return nil
		}
		return configuration.name?.uiImage
			.applyingSymbolConfiguration(configuration.appearence.configuration)?
			.applyingSymbolConfiguration(.init(textStyle: textStyle.value, scale: scale))
	}
}

#elseif os(macOS)

import AppKit

public final class CompositeIcon: NSView {

	// MARK: - UI

	private lazy var iconView: NSImageView = {
		let view = NSImageView()
		view.imageAlignment = .alignCenter
		view.imageScaling = .scaleNone
		return view
	}()

	private lazy var badgeIconView: NSImageView = {
		let view = NSImageView()
		view.imageAlignment = .alignCenter
		view.imageScaling = .scaleProportionallyDown
		return view
	}()

	private lazy var badgeBackgroundView: NSView = {
		let view = NSView()
		view.wantsLayer = true
		view.layer?.backgroundColor = NSColor.controlBackgroundColor.cgColor
		view.layer?.cornerCurve = .continuous
		view.layer?.masksToBounds = true
		view.addSubview(badgeIconView)
		return view
	}()

	// MARK: - State

	public var iconConfiguration: IconConfiguration? {
		didSet {
			updateForCurrentTraits()
		}
	}
	public var badgeConfiguration: IconConfiguration? {
		didSet {
			updateForCurrentTraits()
		}
	}
	public var textStyle: TextStyle = .body {
		didSet {
			updateForCurrentTraits()
		}
	}

	private let iconBaseSide: CGFloat = 28
	private let badgeSideRatio: CGFloat = 16 / 28
	private let badgePaddingRatio: CGFloat = 2 / 28
	private let referenceFontPointSize = NSFont.preferredFont(forTextStyle: .body).pointSize

	// MARK: - Initialization

	public init() {
		super.init(frame: .zero)
		addSubviews()
	}

	@available(*, unavailable, message: "Use init()")
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

// MARK: - Configuration
public extension CompositeIcon {

	func animate() {
		iconView.addSymbolEffect(.bounce, options: .repeat(1))
	}
}

// MARK: - Layout

extension CompositeIcon {

	public override var intrinsicContentSize: NSSize {
		let badgeSide = semanticIconSide * badgeSideRatio
		return NSSize(
			width: scaled(iconBaseSide) + badgeSide,
			height: semanticIconSide + badgeSide
		)
	}

	public override func layout() {
		super.layout()
		layoutCompositeIcon()
	}
}

// MARK: - View hierarchy

private extension CompositeIcon {

	func addSubviews() {
		addSubview(iconView)
		addSubview(badgeBackgroundView)
		setContentHuggingPriority(.required, for: .horizontal)
		setContentCompressionResistancePriority(.required, for: .horizontal)
	}
}

// MARK: - Layout

private extension CompositeIcon {

	func layoutCompositeIcon() {
		let iconSide = semanticIconSide
		let badgeSide = iconSide * badgeSideRatio
		let iconFrame = NSRect(
			x: (bounds.width - iconSide) / 2,
			y: (bounds.height - iconSide) / 2,
			width: iconSide,
			height: iconSide
		)
		let badgeFrame = NSRect(
			x: iconFrame.minX - badgeSide / 2,
			y: iconFrame.minY - badgeSide / 2,
			width: badgeSide,
			height: badgeSide
		)

		iconView.frame = iconFrame
		badgeBackgroundView.frame = badgeFrame

		let badgePadding = iconSide * badgePaddingRatio
		let badgeIconSide = badgeSide - badgePadding * 2
		badgeIconView.frame = NSRect(
			x: (badgeBackgroundView.bounds.width - badgeIconSide) / 2,
			y: (badgeBackgroundView.bounds.height - badgeIconSide) / 2,
			width: badgeIconSide,
			height: badgeIconSide
		)
	}
}

// MARK: - State updates

private extension CompositeIcon {

	func updateForCurrentTraits() {
		iconView.image = makeImage(configuration: iconConfiguration, scale: .medium)
		iconView.contentTintColor = iconConfiguration?.appearence.tint

		badgeIconView.image = makeImage(configuration: badgeConfiguration, scale: .small)
		badgeIconView.contentTintColor = badgeConfiguration?.appearence.tint

		badgeBackgroundView.isHidden = badgeConfiguration == nil
		badgeBackgroundView.layer?.cornerRadius = semanticIconSide * badgeSideRatio / 2
		invalidateIntrinsicContentSize()
		needsLayout = true
	}
}

// MARK: - Helpers

private extension CompositeIcon {

	func scaled(_ value: CGFloat) -> CGFloat {
		let font = semanticFont
		return value * font.pointSize / referenceFontPointSize
	}

	var semanticFont: NSFont {
		NSFont.preferredFont(forTextStyle: textStyle.value)
	}

	var semanticIconSide: CGFloat {
		semanticFont.boundingRectForFont.height
	}

	func makeImage(
		configuration: IconConfiguration?,
		scale: NSImage.SymbolScale
	) -> NSImage? {
		guard let configuration else {
			return nil
		}
		return configuration.name?.nsImage?
			.withSymbolConfiguration(
				configuration.appearence.configuration
					.applying(.init(textStyle: textStyle.value, scale: scale))
			)
	}
}

#endif

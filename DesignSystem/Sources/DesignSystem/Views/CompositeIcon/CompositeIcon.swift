//
//  CompositeIcon.swift
//  DesignSystem
//

import Foundation
import QuartzCore

#if os(iOS)

import UIKit

public final class CompositeIcon: UIView {

	// MARK: - UI

	private lazy var iconView: UIImageView = {
		let view = UIImageView()
		view.contentMode = .scaleAspectFit
		return view
	}()

	private lazy var badgeIconView: UIImageView = {
		let view = UIImageView()
		view.contentMode = .scaleAspectFit
		return view
	}()

	// MARK: - State

	public var model: CompositeIconModel? {
		didSet {
			updateForCurrentTraits()
		}
	}
	public var textStyle: TextStyle = .body {
		didSet {
			updateForCurrentTraits()
		}
	}

	// MARK: - Constants

	private var contentSizeCategoryObserver: NSObjectProtocol?

	private let badgeSideRatio: CGFloat = 8 / 20
	private let badgePaddingRatio: CGFloat = 1 / 20
	private let badgeOverlapRatio: CGFloat = 0.75

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
public extension CompositeIcon {

	override var intrinsicContentSize: CGSize {
		return iconGeometry.intrinsicContentSize
	}

	override func layoutSubviews() {
		super.layoutSubviews()
		layoutCompositeIcon()
	}
}

// MARK: - View hierarchy
private extension CompositeIcon {

	func addSubviews() {
		addSubview(iconView)
		addSubview(badgeIconView)
		setContentHuggingPriority(.required, for: .horizontal)
		setContentCompressionResistancePriority(.required, for: .horizontal)
		setContentHuggingPriority(.required, for: .vertical)
		setContentCompressionResistancePriority(.required, for: .vertical)
	}
}

// MARK: - Layout
private extension CompositeIcon {

	func layoutCompositeIcon() {
		let isRightToLeft = effectiveUserInterfaceLayoutDirection == .rightToLeft
		let frames = iconGeometry.frames(isRightToLeft: isRightToLeft)

		iconView.frame = frames.mainIcon
		badgeIconView.frame = frames.badgeCutout.insetBy(
			dx: iconGeometry.badgePadding,
			dy: iconGeometry.badgePadding
		)
		updateIconMask(for: frames.badgeCutout)
	}
}

// MARK: - State updates

private extension CompositeIcon {

	func updateForCurrentTraits() {
		iconView.image = makeImage(configuration: model?.icon, scale: .medium)
		iconView.tintColor = model?.icon.appearence.tint
		badgeIconView.image = makeImage(configuration: model?.badge, scale: .small)
		badgeIconView.tintColor = model?.badge?.appearence.tint
		badgeIconView.isHidden = model?.badge == nil
		invalidateIntrinsicContentSize()
		setNeedsLayout()
	}
}

// MARK: - Helpers

private extension CompositeIcon {

	func updateIconMask(for badgeCutoutFrame: CGRect) {
		guard model?.badge != nil else {
			iconView.layer.mask = nil
			return
		}

		let badgeFrame = convert(badgeCutoutFrame, to: iconView)
		iconView.layer.mask = makeCutoutMask(
			in: iconView.bounds,
			cuttingOut: badgeFrame
		)
	}

	var iconGeometry: CompositeIconGeometry {
		CompositeIconGeometry(
			iconWidth: semanticFont.pointSize,
			iconHeight: semanticFont.pointSize,
			badgeSideRatio: badgeSideRatio,
			badgePaddingRatio: badgePaddingRatio,
			badgeOverlapRatio: badgeOverlapRatio
		)
	}

	var semanticFont: UIFont {
		UIFont.preferredFont(forTextStyle: textStyle.value, compatibleWith: traitCollection)
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
		view.wantsLayer = true
		return view
	}()

	private lazy var badgeIconView: NSImageView = {
		let view = NSImageView()
		view.imageAlignment = .alignCenter
		view.imageScaling = .scaleProportionallyDown
		return view
	}()

	// MARK: - State

	public var model: CompositeIconModel? {
		didSet {
			updateForCurrentTraits()
		}
	}
	public var textStyle: TextStyle = .body {
		didSet {
			updateForCurrentTraits()
		}
	}

	private let iconBaseSide: CGFloat = 18
	private let badgeSideRatio: CGFloat = 7 / 20
	private let badgePaddingRatio: CGFloat = 1 / 20
	private let badgeOverlapRatio: CGFloat = 0.85

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
		return iconGeometry.intrinsicContentSize
	}

	public override var firstBaselineOffsetFromTop: CGFloat {
		let viewHeight = bounds.height > 0 ? bounds.height : intrinsicContentSize.height
		return viewHeight - mainIconBaselineOffsetFromBottom
	}

	public override var lastBaselineOffsetFromBottom: CGFloat {
		return mainIconBaselineOffsetFromBottom
	}

	public override func layout() {
		super.layout()
		layoutCompositeIcon()
	}
}

// MARK: - View hierarchy

private extension CompositeIcon {

	func addSubviews() {
		[iconView, badgeIconView].forEach { addSubview($0) }
		[
			NSLayoutConstraint.Orientation.horizontal,
			NSLayoutConstraint.Orientation.vertical
		].forEach { orientation in
			setContentHuggingPriority(.required, for: orientation)
			setContentCompressionResistancePriority(.required, for: orientation)
		}
	}
}

// MARK: - Layout

private extension CompositeIcon {

	func layoutCompositeIcon() {
		let isRightToLeft = userInterfaceLayoutDirection == .rightToLeft
		let frames = iconGeometry.frames(isRightToLeft: isRightToLeft)

		iconView.frame = frames.mainIcon
		badgeIconView.frame = frames.badgeCutout.insetBy(
			dx: iconGeometry.badgePadding,
			dy: iconGeometry.badgePadding
		)
		updateIconMask(for: frames.badgeCutout)
	}
}

// MARK: - State updates

private extension CompositeIcon {

	func updateForCurrentTraits() {
		iconView.image = makeImage(configuration: model?.icon, scale: .medium)
		iconView.contentTintColor = model?.icon.appearence.tint

		badgeIconView.image = makeImage(configuration: model?.badge, scale: .small)
		badgeIconView.contentTintColor = model?.badge?.appearence.tint

		badgeIconView.isHidden = model?.badge == nil
		invalidateIntrinsicContentSize()
		needsLayout = true
	}
}

// MARK: - Helpers

private extension CompositeIcon {

	func updateIconMask(for badgeCutoutFrame: NSRect) {
		guard model?.badge != nil else {
			iconView.layer?.mask = nil
			return
		}

		let badgeFrame = convert(badgeCutoutFrame, to: iconView)
		iconView.layer?.mask = makeCutoutMask(in: iconView.bounds, cuttingOut: badgeFrame)
	}

	var iconGeometry: CompositeIconGeometry {
		let font = semanticFont
		return CompositeIconGeometry(
			iconWidth: iconBaseSide * font.pointSize / baseFont.pointSize,
			iconHeight: ceil(font.ascender - font.descender + font.leading),
			badgeSideRatio: badgeSideRatio,
			badgePaddingRatio: badgePaddingRatio,
			badgeOverlapRatio: badgeOverlapRatio
		)
	}

	var semanticFont: NSFont {
		NSFont.preferredFont(forTextStyle: textStyle.value)
	}

	var baseFont: NSFont {
		NSFont.preferredFont(forTextStyle: .body)
	}

	var mainIconBaselineOffsetFromBottom: CGFloat {
		guard let image = iconView.image, image.size.width > 0, image.size.height > 0 else {
			return iconGeometry.mainIconOriginY - semanticFont.descender
		}

		let scale = min(iconGeometry.iconWidth / image.size.width, iconGeometry.iconHeight / image.size.height)
		let imageVerticalInset = (iconGeometry.iconHeight - image.size.height * scale) / 2
		return iconGeometry.mainIconOriginY + imageVerticalInset + image.alignmentRect.minY * scale
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
					.applying(
						.init(
							pointSize: semanticFont.pointSize,
							weight: .bold,
							scale: scale
						)
					)
			)
	}
}

#endif

private func makeCutoutMask(in bounds: CGRect, cuttingOut cutoutFrame: CGRect) -> CAShapeLayer {

	let path = CGMutablePath()
	path.addRect(bounds)
	path.addEllipse(in: cutoutFrame)

	let mask = CAShapeLayer()
	mask.frame = bounds
	mask.path = path
	mask.fillColor = CGColor(gray: 1, alpha: 1)
	mask.fillRule = .evenOdd

	return mask
}

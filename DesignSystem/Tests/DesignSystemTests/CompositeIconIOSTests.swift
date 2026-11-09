#if os(iOS)
import UIKit
import Testing
@testable import DesignSystem

@MainActor struct CompositeIconIOSTests { }

// MARK: - Layout
extension CompositeIconIOSTests {

	@Test func layout_fitsNativeImagesInFixedWidthColumn() throws {
		for textStyle in [TextStyle.body, .callout, .headline] {
			for icon in Self.icons {
				// Arrange
				let sut = CompositeIcon()
				sut.textStyle = textStyle
				let initialWidth = sut.intrinsicContentSize.width
				sut.model = CompositeIconModel(
					icon: IconConfiguration(name: icon, token: .primary),
					badge: IconConfiguration(name: .link, token: .secondary)
				)
				sut.frame = CGRect(origin: .zero, size: sut.intrinsicContentSize)

				// Act
				sut.layoutIfNeeded()

				// Assert
				let mainIcon = try #require(sut.subviews.first as? UIImageView)
				let badgeIcon = try #require(sut.subviews.last as? UIImageView)
				let image = try #require(mainIcon.image)
				#expect(sut.intrinsicContentSize.width == initialWidth)
				#expect(mainIcon.contentMode == .center)
				#expect(mainIcon.bounds.width >= image.size.width)
				#expect(mainIcon.bounds.height >= image.size.height)
				let contentBounds = mainIcon.frame.union(badgeIcon.frame)
				#expect(abs(contentBounds.minY - sut.bounds.minY) < 0.0001)
				#expect(abs(contentBounds.maxY - sut.bounds.maxY) < 0.0001)
				#expect(sut.bounds.contains(mainIcon.frame))
				#expect(sut.bounds.contains(badgeIcon.frame))
			}
		}
	}

	@Test func layout_rightToLeftMirrorsBadgePlacement() throws {
		// Arrange
		let sut = CompositeIcon()
		sut.model = CompositeIconModel(
			icon: IconConfiguration(name: .folder, token: .primary),
			badge: IconConfiguration(name: .link, token: .secondary)
		)
		sut.frame = CGRect(origin: .zero, size: sut.intrinsicContentSize)
		sut.semanticContentAttribute = .forceLeftToRight
		sut.layoutIfNeeded()
		let mainIcon = try #require(sut.subviews.first as? UIImageView)
		let badgeIcon = try #require(sut.subviews.last as? UIImageView)
		let initialMainFrame = mainIcon.frame
		let initialBadgeFrame = badgeIcon.frame

		// Act
		sut.semanticContentAttribute = .forceRightToLeft
		sut.setNeedsLayout()
		sut.layoutIfNeeded()

		// Assert
		#expect(abs(mainIcon.frame.minX - (sut.bounds.width - initialMainFrame.maxX)) < 0.0001)
		#expect(abs(badgeIcon.frame.minX - (sut.bounds.width - initialBadgeFrame.maxX)) < 0.0001)
		#expect(badgeIcon.frame.minY == initialBadgeFrame.minY)
		#expect(sut.bounds.contains(badgeIcon.frame))
	}
}

// MARK: - Intrinsic content size
extension CompositeIconIOSTests {

	@Test func intrinsicContentSize_addingBadgePreservesReservedSpace() {
		// Arrange
		let sut = CompositeIcon()
		let icon = IconConfiguration(name: .folder, token: .primary)
		sut.model = CompositeIconModel(icon: icon, badge: nil)
		let initialSize = sut.intrinsicContentSize

		// Act
		sut.model = CompositeIconModel(
			icon: icon,
			badge: IconConfiguration(name: .link, token: .secondary)
		)

		// Assert
		#expect(sut.intrinsicContentSize == initialSize)
	}

	@Test func intrinsicContentSize_scalesWithContentSizeCategory() throws {
		// Arrange
		let parent = UIViewController()
		let child = UIViewController()
		parent.addChild(child)
		parent.view.addSubview(child.view)
		child.didMove(toParent: parent)
		let window = UIWindow(frame: UIScreen.main.bounds)
		window.rootViewController = parent
		window.isHidden = false
		defer { window.isHidden = true }
		let sut = CompositeIcon()
		child.view.addSubview(sut)
		let model = CompositeIconModel(
			icon: IconConfiguration(name: .folder, token: .primary),
			badge: IconConfiguration(name: .link, token: .secondary)
		)
		parent.setOverrideTraitCollection(
			UITraitCollection(preferredContentSizeCategory: .large),
			forChild: child
		)
		parent.view.layoutIfNeeded()
		sut.model = model
		let initialSize = sut.intrinsicContentSize
		let mainIcon = try #require(sut.subviews.first as? UIImageView)
		let initialImageSize = try #require(mainIcon.image).size

		// Act
		parent.setOverrideTraitCollection(
			UITraitCollection(preferredContentSizeCategory: .accessibilityExtraExtraExtraLarge),
			forChild: child
		)
		parent.view.layoutIfNeeded()
		NotificationCenter.default.post(name: UIContentSizeCategory.didChangeNotification, object: nil)
		sut.frame = CGRect(origin: .zero, size: sut.intrinsicContentSize)
		sut.layoutIfNeeded()

		// Assert
		let image = try #require(mainIcon.image)
		#expect(sut.intrinsicContentSize.width > initialSize.width)
		#expect(sut.intrinsicContentSize.height > initialSize.height)
		#expect(image.size.width > initialImageSize.width)
		#expect(mainIcon.bounds.width >= image.size.width)
		#expect(mainIcon.bounds.height >= image.size.height)
	}
}

// MARK: - Nested data structs
private extension CompositeIconIOSTests {

	static let icons: [SemanticImage] = [
		.point, .circleSlash, .filledCircle, .folder, .textDoc, .docOnDoc,
		.shippingbox, .archivebox, .squareStack, .book, .squareGrid2x2,
		.star, .heart, .listStar, .bolt, .person, .cloud, .sun, .moonStars,
		.sparkles, .flame, .creditcard, .gift, .trash, .receipt, .terminal,
		.calendar, .clock, .xmarkApp, .checkmarkApp, .xmarkDiamond,
		.checkmarkDiamond, .pc, .location, .bookmark, .tag, .squareOnSquare,
		.link, .linkPoint, .insetDiamond, .insetCircle, .insetSquare, .insetTriangle,
		.personGroup, .leaf, .house, .bell, .conversation, .envelope, .gearshape,
		.suitcase, .key, .airplane, .carRear, .film, .photo, .photoOnRectangle,
		.asteriskPoint, .diamondPoint, .starPoint, .stopPoint
	]
}
#endif

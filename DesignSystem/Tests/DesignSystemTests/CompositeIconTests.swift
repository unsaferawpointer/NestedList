#if os(macOS)
import AppKit
import Testing
@testable import DesignSystem

@MainActor struct CompositeIconTests { }

// MARK: - Intrinsic content size
extension CompositeIconTests {

	@Test func intrinsicContentSize_tightlyEnclosesMainIconAndBadgeVertically() throws {
		for textStyle in [TextStyle.body, .callout, .headline] {
			// Arrange
			let sut = CompositeIcon()
			sut.textStyle = textStyle
			sut.model = CompositeIconModel(
				icon: IconConfiguration(name: .folder, token: .primary),
				badge: IconConfiguration(name: .link, token: .secondary)
			)
			sut.frame = CGRect(origin: .zero, size: sut.intrinsicContentSize)

			// Act
			sut.layoutSubtreeIfNeeded()

			// Assert
			let mainIcon = try #require(sut.subviews.first as? NSImageView)
			let badgeIcon = try #require(sut.subviews.last as? NSImageView)
			let contentBounds = mainIcon.frame.union(badgeIcon.frame)
			#expect(abs(contentBounds.minY - sut.bounds.minY) < 0.0001)
			#expect(abs(contentBounds.maxY - sut.bounds.maxY) < 0.0001)
		}
	}

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
}

// MARK: - Layout
extension CompositeIconTests {

	@Test(arguments: [false, true])
	func layout_fitsIconsAtNativeSizeInFixedWidthColumn(showsBadge: Bool) throws {
		for textStyle in [TextStyle.body, .callout, .headline] {
			for icon in Self.icons {
				// Arrange
				let sut = CompositeIcon()
				sut.textStyle = textStyle
				let initialWidth = sut.intrinsicContentSize.width
				sut.model = CompositeIconModel(
					icon: IconConfiguration(name: icon, token: .primary),
					badge: showsBadge ? IconConfiguration(name: .link, token: .secondary) : nil
				)
				sut.frame = CGRect(origin: .zero, size: sut.intrinsicContentSize)

				// Act
				sut.layoutSubtreeIfNeeded()

				// Assert
				let mainIcon = try #require(sut.subviews.first as? NSImageView)
				let image = try #require(mainIcon.image)
				#expect(sut.intrinsicContentSize.width == initialWidth)
				#expect(mainIcon.imageScaling == .scaleNone)
				#expect(mainIcon.bounds.width >= image.size.width)
				#expect(mainIcon.bounds.height >= image.size.height)
				#expect(sut.bounds.contains(mainIcon.frame))
				let imageBaseline = mainIcon.frame.midY - image.size.height / 2 + image.alignmentRect.minY
				#expect(abs(sut.lastBaselineOffsetFromBottom - imageBaseline) < 0.0001)
			}
		}
	}

	@Test func layout_changingIconPreservesColumnWidthAndBadgeSize() throws {
		// Arrange
		let sut = CompositeIcon()
		let badge = IconConfiguration(name: .link, token: .secondary)
		sut.model = CompositeIconModel(
			icon: IconConfiguration(name: .folder, token: .primary),
			badge: badge
		)
		sut.frame = CGRect(origin: .zero, size: sut.intrinsicContentSize)
		sut.layoutSubtreeIfNeeded()
		let initialWidth = sut.intrinsicContentSize.width
		let badgeIcon = try #require(sut.subviews.last as? NSImageView)
		let initialBadgeSize = badgeIcon.frame.size

		// Act
		sut.model = CompositeIconModel(
			icon: IconConfiguration(name: .conversation, token: .primary),
			badge: badge
		)
		sut.frame = CGRect(origin: .zero, size: sut.intrinsicContentSize)
		sut.layoutSubtreeIfNeeded()

		// Assert
		#expect(sut.intrinsicContentSize.width == initialWidth)
		#expect(badgeIcon.frame.size == initialBadgeSize)
		#expect(sut.bounds.contains(badgeIcon.frame))
	}

	@Test func layout_usesFontHeightAndKeepsBadgeWithinBounds() throws {
		for textStyle in [TextStyle.body, .callout, .headline] {
			// Arrange
			let sut = CompositeIcon()
			sut.textStyle = textStyle
			sut.model = CompositeIconModel(
				icon: IconConfiguration(name: .folder, token: .primary),
				badge: IconConfiguration(name: .link, token: .secondary)
			)
			sut.frame = CGRect(origin: .zero, size: sut.intrinsicContentSize)

			// Act
			sut.layoutSubtreeIfNeeded()

			// Assert
			let mainIcon = try #require(sut.subviews.first as? NSImageView)
			let badgeIcon = try #require(sut.subviews.last as? NSImageView)
			let font = NSFont.preferredFont(forTextStyle: textStyle.value)
			#expect(mainIcon.frame.height == NSLayoutManager().defaultLineHeight(for: font))
			#expect(mainIcon.frame.maxY == sut.bounds.maxY)
			#expect(sut.bounds.contains(mainIcon.frame))
			#expect(sut.bounds.contains(badgeIcon.frame))
		}
	}
}

// MARK: - Nested data structs
private extension CompositeIconTests {

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

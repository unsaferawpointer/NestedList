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
#endif

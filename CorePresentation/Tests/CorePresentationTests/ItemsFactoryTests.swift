//
//  ItemsFactoryTests.swift
//  CorePresentationTests
//
//  Created by Anton Cherkasov on 05.10.2026.
//

import CoreModule
import DesignSystem
import Foundation
import Testing
@testable import CorePresentation

struct ItemsFactoryTests { }

// MARK: - ItemsFactory
extension ItemsFactoryTests {

	@Test func makeItem_whenItemIsLeaf_createsItemPresentation() {
		// Arrange
		let item = Item(
			uuid: UUID(),
			text: "Title",
			note: "Note",
			iconName: .bolt,
			tintColor: .cyan
		)
		let sut = ItemsFactory()

		// Act
		let result = sut.makeItem(item: item, isLeaf: true, iconColor: .multicolor)

		// Assert
		#expect(result.id == item.id)
		#expect(result.title == .init(value: item.text, style: .body, colorToken: .primary, strikethrough: false))
		#expect(result.subtitle == .init(value: "Note", style: .callout, colorToken: .secondary, strikethrough: false))
		#expect(result.compositeIcon == .init(
			icon: .init(name: .bolt, appearence: .monochrome(token: .cyan)),
			badge: nil
		))
		#expect(result.showsTrailingDisclosure == false)
		#expect(result.isGroup == false)
	}

	@Test func makeItem_whenItemIsStrikethrough_usesDisabledAppearance() {
		// Arrange
		let item = Item(text: "Title", options: [.strikethrough], iconName: .bolt, tintColor: .cyan)
		let sut = ItemsFactory()

		// Act
		let result = sut.makeItem(item: item, isLeaf: true, iconColor: .multicolor)

		// Assert
		#expect(result.title.colorToken == .disabledText)
		#expect(result.title.strikethrough)
		#expect(result.compositeIcon == .init(
			icon: .init(name: .bolt, appearence: .monochrome(token: .tertiary)),
			badge: nil
		))
	}

	@Test func makeItem_whenItemIsGroup_createsHeadlinePresentation() {
		// Arrange
		let item = Item(text: "Title", iconName: .folder)
		let sut = ItemsFactory()

		// Act
		let result = sut.makeItem(item: item, isLeaf: false, iconColor: .neutral)

		// Assert
		#expect(result.title.style == .headline)
		#expect(result.isGroup)
		#expect(result.compositeIcon == .init(
			icon: .init(name: .folder, appearence: .monochrome(token: .tertiary)),
			badge: nil
		))
	}

	@Test func makeItem_whenMirrorDoesNotHaveIcon_usesLinkAsMainIcon() {
		// Arrange
		var item = Item(text: "Title", tintColor: .cyan)
		item.isMirror = true
		let sut = ItemsFactory()

		// Act
		let result = sut.makeItem(item: item, isLeaf: true, iconColor: .multicolor)

		// Assert
		#expect(result.compositeIcon == .init(
			icon: .init(name: .linkPoint, appearence: .monochrome(token: .cyan)),
			badge: nil
		))
	}

	@Test func makeItem_whenMirrorHasIcon_createsBadge() {
		// Arrange
		var item = Item(text: "Title", iconName: .bolt)
		item.isMirror = true
		let sut = ItemsFactory()

		// Act
		let result = sut.makeItem(item: item, isLeaf: true, iconColor: .neutral)

		// Assert
		#expect(result.compositeIcon == .init(
			icon: .init(name: .bolt, appearence: .monochrome(token: .tertiary)),
			badge: .init(name: .link, appearence: .monochrome(token: .tertiary))
		))
	}

	@Test func makeItem_whenSubitemsAreHidden_showsTrailingDisclosure() {
		// Arrange
		let item = Item(text: "Title", options: [.hideSubitems])
		let sut = ItemsFactory()

		// Act
		let result = sut.makeItem(item: item, isLeaf: true, iconColor: .neutral)

		// Assert
		#expect(result.showsTrailingDisclosure)
	}

	@Test func makeItem_whenItemDoesNotHaveIcon_returnsNilCompositeIcon() {
		// Arrange
		let item = Item(text: "Title")
		let sut = ItemsFactory()

		// Act
		let result = sut.makeItem(item: item, isLeaf: true, iconColor: .neutral)

		// Assert
		#expect(result.compositeIcon == nil)
	}

	@Test(arguments: [
		(IconColor.neutral, IconAppearence.monochrome(token: .tertiary)),
		(.accent, .monochrome(token: .accent)),
		(.primary, .monochrome(token: .primary))
	])
	func makeItem_whenIconColorIsMonochrome_usesConfiguredColor(
		iconColor: IconColor,
		expectedAppearance: IconAppearence
	) {
		// Arrange
		let item = Item(text: "Title", iconName: .bolt, tintColor: .yellow)
		let sut = ItemsFactory()

		// Act
		let result = sut.makeItem(item: item, isLeaf: true, iconColor: iconColor)

		// Assert
		#expect(result.compositeIcon == .init(
			icon: .init(name: .bolt, appearence: expectedAppearance),
			badge: nil
		))
	}
}

//
//  ItemsFactoryTests.swift
//  iOSTests
//
//  Created by Anton Cherkasov on 19.03.2026.
//

import Testing
import UIKit
import CoreModule
import DesignSystem
import CorePresentation
@testable import iOS

struct ItemsFactoryTests {

	@Test func makeItem_whenAppearanceIsMulticolor() {
		// Arrange
		let sut = ItemsFactory()

		let item = Item(
			uuid: UUID(),
			text: .random,
			note: .random,
			iconName: .bolt,
			tintColor: .cyan
		)

		// Act
		let result = sut.makeItem(item: item, isLeaf: true, iconColor: .multicolor)

		// Assert
		#expect(result.id == item.id)

		#expect(result.title.text == item.text)
		#expect(result.subtitle?.text == item.note)
		#expect(result.title.style == .body)
		#expect(result.title.colorToken == .primary)
		#expect(!result.title.strikethrough)

		#expect(result.icon?.appearence == .monochrome(token: .cyan))
		#expect(result.icon?.name == .bolt)
	}

	@Test func makeItem_whenAppearanceIsNeutral() {
		// Act
		checkTint(reference: .monochrome(token: .tertiary), for: .neutral)
	}

	@Test func makeItem_whenAppearanceIsAccent() {
		// Act
		checkTint(reference: .monochrome(token: .accent), for: .accent)
	}

	@Test func makeItem_whenAppearanceIsPrimary() {
		// Act
		checkTint(reference: .monochrome(token: .primary), for: .primary)
	}

	@Test func makeItem_when_itemIsStrikethrough() {
		// Arrange
		let sut = ItemsFactory()

		let item = Item(text: .random, options: [.strikethrough], tintColor: .cyan)

		// Act
		let result = sut.makeItem(item: item, isLeaf: true, iconColor: .multicolor)

		// Assert
		#expect(result.title.text == item.text)
		#expect(result.subtitle == nil)
		#expect(result.title.style == .body)
		#expect(result.title.colorToken == .disabledText)
		#expect(result.title.strikethrough)

		#expect(result.icon?.appearence == .monochrome(token: .tertiary))
	}

	@Test func makeItem_when_itemIsGroup() {
		// Arrange
		let sut = ItemsFactory()

		let item = Item(text: .random, options: [])

		// Act
		let result = sut.makeItem(item: item, isLeaf: false, iconColor: .multicolor)

		// Assert
		#expect(result.title.text == item.text)
		#expect(result.subtitle == nil)
		#expect(result.title.style == .headline)
		#expect(result.title.colorToken == .primary)
		#expect(!result.title.strikethrough)

		#expect(result.icon?.appearence == .monochrome(token: .tertiary))
	}

	@Test func makeItem_when_itemIsSectionAndStrikethrough() {
		// Arrange
		let sut = ItemsFactory()

		let item = Item(text: .random, options: [.strikethrough])

		// Act
		let result = sut.makeItem(item: item, isLeaf: false, iconColor: .multicolor)

		// Assert
		#expect(result.title.text == item.text)
		#expect(result.subtitle == nil)
		#expect(result.title.style == .headline)
		#expect(result.title.colorToken == .disabledText)
		#expect(result.title.strikethrough)

		#expect(result.icon?.appearence == .monochrome(token: .tertiary))
	}
}

// MARK: - Private
private extension ItemsFactoryTests {

	func checkTint(reference: IconAppearence, for appearance: IconColor) {
		// Arrange
		let sut = ItemsFactory()

		let item = Item(
			uuid: UUID(),
			text: .random,
			note: .random,
			iconName: .bolt,
			tintColor: .yellow
		)

		// Act
		let result = sut.makeItem(item: item, isLeaf: true, iconColor: appearance)

		// Assert
		#expect(result.icon?.appearence == reference)
	}
}

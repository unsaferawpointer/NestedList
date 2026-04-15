//
//  ItemsFactoryTests.swift
//  macOSTests
//
//  Created by Anton Cherkasov on 12.01.2025.
//

import Testing
import CoreModule
@testable import Nested_List

struct ItemsFactoryTests {

	@Test func makeItem() {
		// Arrange
		let sut = ItemsFactory()

		let item = Item(
			uuid: .random,
			text: .random,
			note: .random
		)

		// Act
		let result = sut.makeItem(item: item, isLeaf: true, iconColor: .neutral)

		// Assert
		#expect(result.isGroup == false)
		#expect(result.value.title == item.text)
		#expect(result.value.subtitle == item.note)
		#expect(result.configuration.text.colorToken == .primary)
		#expect(!result.configuration.text.strikethrough)
	}

	@Test func makeItem_when_itemIsCompleted() {
		// Arrange
		let sut = ItemsFactory()

		let item = Item(text: .random, options: [.strikethrough])

		// Act
		let result = sut.makeItem(item: item, isLeaf: true, iconColor: .neutral)

		// Assert
		#expect(result.isGroup == false)
		#expect(result.value.title == item.text)
		#expect(result.value.subtitle == nil)
		#expect(result.configuration.text.colorToken == .disabledText)
		#expect(result.configuration.text.strikethrough)
	}

	@Test func makeItem_when_itemIsCompletedAndMarked() {
		// Arrange
		let sut = ItemsFactory()

		let item = Item(text: .random, options: [.strikethrough])

		// Act
		let result = sut.makeItem(item: item, isLeaf: true, iconColor: .neutral)

		// Assert
		#expect(result.isGroup == false)
		#expect(result.value.title == item.text)
		#expect(result.value.subtitle == nil)
		#expect(result.configuration.text.colorToken == .disabledText)
		#expect(result.configuration.text.strikethrough)
	}

	@Test func makeSection_whenTintColorIsAccent() {
		// Arrange
		let sut = ItemsFactory()

		let item = Item(text: .random, options: [], iconName: .document, tintColor: .tertiary)

		// Act
		let result = sut.makeItem(item: item, isLeaf: false, iconColor: .accent)

		// Assert
		#expect(result.isGroup)
		#expect(result.value.title == item.text)
		#expect(result.configuration.text.colorToken == .primary)
		#expect(!result.configuration.text.strikethrough)
		#expect(result.configuration.icon?.name == .textDoc)
		#expect(result.configuration.icon?.appearence == .monochrome(token: .accent))
	}

	@Test func makeSection_whenSectionIsGroup() {
		// Arrange
		let sut = ItemsFactory()

		let item = Item(text: .random, iconName: .folder, tintColor: .tertiary)

		// Act
		let result = sut.makeItem(item: item, isLeaf: false, iconColor: .neutral)

		// Assert
		#expect(result.isGroup)
		#expect(result.value.title == item.text)
		#expect(result.configuration.text.colorToken == .primary)
		#expect(!result.configuration.text.strikethrough)
		#expect(result.configuration.icon?.name == .folder)
		#expect(result.configuration.icon?.appearence == .monochrome(token: .tertiary))
	}

	@Test func makeSection_whenStyleIsIconAndMarked() {
		// Arrange
		let sut = ItemsFactory()

		let item = Item(text: .random, options: [], iconName: .package, tintColor: .yellow)

		// Act
		let result = sut.makeItem(item: item, isLeaf: false, iconColor: .multicolor)

		// Assert
		#expect(result.isGroup)
		#expect(result.value.title == item.text)
		#expect(result.configuration.text.colorToken == .primary)
		#expect(!result.configuration.text.strikethrough)
		#expect(result.configuration.icon?.name == .shippingbox)
		#expect(result.configuration.icon?.appearence == .monochrome(token: .yellow))
	}

	@Test func makeItem_whenIconImageHasPreferredAppearance() {
		// Arrange
		let sut = ItemsFactory()

		let item = Item(text: .random, options: [], iconName: .xmarkDiamond, tintColor: .yellow)

		// Act
		let result = sut.makeItem(item: item, isLeaf: false, iconColor: .multicolor)

		// Assert
		#expect(result.isGroup)
		#expect(result.value.title == item.text)
		#expect(result.configuration.text.colorToken == .primary)
		#expect(!result.configuration.text.strikethrough)
		#expect(result.configuration.icon?.name == .xmarkDiamond)
		#expect(result.configuration.icon?.appearence == .monochrome(token: .yellow))
	}

	@Test func makeSection_when_sectionIsCompleted() {
		// Arrange
		let sut = ItemsFactory()

		let item = Item(text: .random, options: [.strikethrough], iconName: nil, tintColor: nil)

		// Act
		let result = sut.makeItem(item: item, isLeaf: false, iconColor: .neutral)

		// Assert
		#expect(result.isGroup)
		#expect(result.value.title == item.text)
		#expect(result.configuration.text.colorToken == .disabledText)
		#expect(result.configuration.text.strikethrough)
	}

	@Test func makeSection_when_sectionIsCompletedAndMarked() {
		// Arrange
		let sut = ItemsFactory()

		let item = Item(text: .random, options: [.strikethrough], iconName: nil, tintColor: nil)

		// Act
		let result = sut.makeItem(item: item, isLeaf: false, iconColor: .neutral)

		// Assert
		#expect(result.isGroup)
		#expect(result.value.title == item.text)
		#expect(result.configuration.text.colorToken == .disabledText)
		#expect(result.configuration.text.strikethrough)
	}
}

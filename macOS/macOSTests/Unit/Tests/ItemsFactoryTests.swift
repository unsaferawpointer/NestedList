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
		let result = sut.makeItem(item: item, level: 0, iconColor: .neutral)

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
		let result = sut.makeItem(item: item, level: 0, iconColor: .neutral)

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

		let item = Item(text: .random, options: [.strikethrough, .marked])

		// Act
		let result = sut.makeItem(item: item, level: 0,iconColor: .neutral)

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

		let item = Item(text: .random, options: [], style: .section(icon: .document))

		// Act
		let result = sut.makeItem(item: item, level: 0, iconColor: .accent)

		// Assert
		#expect(result.isGroup)
		#expect(result.value.title == item.text)
		#expect(result.configuration.text.colorToken == .primary)
		#expect(!result.configuration.text.strikethrough)
		#expect(result.configuration.icon?.name == .textDoc(filled: false))
		#expect(result.configuration.icon?.appearence == .monochrome(token: .accent))
	}

	@Test func makeSection_whenSectionIsGroup() {
		// Arrange
		let sut = ItemsFactory()

		let item = Item(text: .random, style: .section(icon: .folder))

		// Act
		let result = sut.makeItem(item: item, level: 1, iconColor: .neutral)

		// Assert
		#expect(result.isGroup)
		#expect(result.value.title == item.text)
		#expect(result.configuration.text.colorToken == .primary)
		#expect(!result.configuration.text.strikethrough)
		#expect(result.configuration.icon?.name == .folder(filled: false))
		#expect(result.configuration.icon?.appearence == .monochrome(token: .tertiary))
	}

	@Test func makeSection_whenStyleIsIconAndMarked() {
		// Arrange
		let sut = ItemsFactory()

		let item = Item(text: .random, options: [.marked], style: .section(icon: .package))

		// Act
		let result = sut.makeItem(item: item, level: 0, iconColor: .neutral)

		// Assert
		#expect(result.isGroup)
		#expect(result.value.title == item.text)
		#expect(result.configuration.text.colorToken == .primary)
		#expect(!result.configuration.text.strikethrough)
		#expect(result.configuration.icon?.name == .shippingbox(filled: false))
		#expect(result.configuration.icon?.appearence == .hierarchical(token: .yellow))
	}

	@Test func makeSection_when_sectionIsCompleted() {
		// Arrange
		let sut = ItemsFactory()

		let item = Item(text: .random, options: [.strikethrough], style: .section(icon: nil))

		// Act
		let result = sut.makeItem(item: item, level: 0, iconColor: .neutral)

		// Assert
		#expect(result.isGroup)
		#expect(result.value.title == item.text)
		#expect(result.configuration.text.colorToken == .disabledText)
		#expect(result.configuration.text.strikethrough)
	}

	@Test func makeSection_when_sectionIsCompletedAndMarked() {
		// Arrange
		let sut = ItemsFactory()

		let item = Item(text: .random, options: [.strikethrough, .marked], style: .section(icon: nil))

		// Act
		let result = sut.makeItem(item: item, level: 0, iconColor: .neutral)

		// Assert
		#expect(result.isGroup)
		#expect(result.value.title == item.text)
		#expect(result.configuration.text.colorToken == .disabledText)
		#expect(result.configuration.text.strikethrough)
	}
}

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
			isDone: false,
			text: .random,
			note: .random,
			style: .item
		)

		// Act
		let result = sut.makeItem(item: item, level: 0, sectionStyle: .icon)

		// Assert
		#expect(result.isGroup == false)
		#expect(result.value.title == item.text)
		#expect(result.value.subtitle == item.note)
		#expect(result.configuration.text.colorToken == .primary)
		#expect(!result.configuration.text.strikethrough)
		#expect(result.configuration.point?.color == .quaternary)
	}

	@Test func makeItem_when_itemIsCompleted() {
		// Arrange
		let sut = ItemsFactory()

		let item = Item(
			uuid: .random,
			isDone: true,
			text: .random,
			style: .item
		)

		// Act
		let result = sut.makeItem(item: item, level: 0, sectionStyle: .icon)

		// Assert
		#expect(result.isGroup == false)
		#expect(result.value.title == item.text)
		#expect(result.value.subtitle == nil)
		#expect(result.configuration.text.colorToken == .disabledText)
		#expect(result.configuration.text.strikethrough)
		#expect(result.configuration.point?.color == .quaternary)
	}

	@Test func makeItem_when_itemIsCompletedAndMarked() {
		// Arrange
		let sut = ItemsFactory()

		let item = Item(
			uuid: .random,
			isDone: true,
			isMarked: true,
			text: .random,
			style: .item
		)

		// Act
		let result = sut.makeItem(item: item, level: 0, sectionStyle: .icon)

		// Assert
		#expect(result.isGroup == false)
		#expect(result.value.title == item.text)
		#expect(result.value.subtitle == nil)
		#expect(result.configuration.text.colorToken == .disabledText)
		#expect(result.configuration.text.strikethrough)
		#expect(result.configuration.point?.color == .quaternary)
	}

	@Test func makeSection_whenStyleIsIconAndLevelEqualsZero() {
		// Arrange
		let sut = ItemsFactory()

		let item = Item(
			uuid: .random,
			isDone: false,
			text: .random,
			style: .section
		)

		// Act
		let result = sut.makeItem(item: item, level: 0, sectionStyle: .icon)

		// Assert
		#expect(result.isGroup)
		#expect(result.value.title == item.text)
		#expect(result.configuration.text.colorToken == .primary)
		#expect(!result.configuration.text.strikethrough)
		#expect(result.configuration.point == nil)
		#expect(result.configuration.icon?.name == .named("custom.folder.fill"))
		#expect(result.configuration.icon?.appearence == .hierarchical(token: .cyan))
	}

	@Test func makeSection_whenStyleIsIconAndLevelIsGreaterThanZero() {
		// Arrange
		let sut = ItemsFactory()

		let item = Item(
			uuid: .random,
			isDone: false,
			text: .random,
			style: .section
		)

		// Act
		let result = sut.makeItem(item: item, level: 1, sectionStyle: .icon)

		// Assert
		#expect(result.isGroup)
		#expect(result.value.title == item.text)
		#expect(result.configuration.text.colorToken == .primary)
		#expect(!result.configuration.text.strikethrough)
		#expect(result.configuration.point == nil)
		#expect(result.configuration.icon?.name == .named("custom.document.on.document.fill"))
		#expect(result.configuration.icon?.appearence == .hierarchical(token: .gray))
	}

	@Test func makeSection_whenStyleIsIconAndMarked() {
		// Arrange
		let sut = ItemsFactory()

		let item = Item(
			uuid: .random,
			isDone: false,
			isMarked: true,
			text: .random,
			style: .section
		)

		// Act
		let result = sut.makeItem(item: item, level: 0, sectionStyle: .icon)

		// Assert
		#expect(result.isGroup)
		#expect(result.value.title == item.text)
		#expect(result.configuration.text.colorToken == .primary)
		#expect(!result.configuration.text.strikethrough)
		#expect(result.configuration.point == nil)
		#expect(result.configuration.icon?.name == .named("custom.folder.fill"))
		#expect(result.configuration.icon?.appearence == .hierarchical(token: .yellow))
	}

	@Test func makeSection_whenStyleIsPoint() {
		// Arrange
		let sut = ItemsFactory()

		let item = Item(
			uuid: .random,
			isDone: false,
			text: .random,
			style: .section
		)

		// Act
		let result = sut.makeItem(item: item, level: 0, sectionStyle: .point)

		// Assert
		#expect(result.isGroup)
		#expect(result.value.title == item.text)
		#expect(result.configuration.text.colorToken == .primary)
		#expect(!result.configuration.text.strikethrough)
		#expect(result.configuration.icon == nil)
		#expect(result.configuration.point != nil)
	}

	@Test func makeSection_whenStyleIsNoIcon() {
		// Arrange
		let sut = ItemsFactory()

		let item = Item(
			uuid: .random,
			isDone: false,
			text: .random,
			style: .section
		)

		// Act
		let result = sut.makeItem(item: item, level: 0, sectionStyle: .noIcon)

		// Assert
		#expect(result.isGroup)
		#expect(result.value.title == item.text)
		#expect(result.configuration.text.colorToken == .primary)
		#expect(!result.configuration.text.strikethrough)
		#expect(result.configuration.icon == nil)
		#expect(result.configuration.point == nil)
	}

	@Test func makeSection_when_sectionIsCompleted() {
		// Arrange
		let sut = ItemsFactory()

		let item = Item(
			uuid: .random,
			isDone: true,
			text: .random,
			style: .section
		)

		// Act
		let result = sut.makeItem(item: item, level: 0, sectionStyle: .icon)

		// Assert
		#expect(result.isGroup)
		#expect(result.value.title == item.text)
		#expect(result.configuration.text.colorToken == .disabledText)
		#expect(result.configuration.text.strikethrough)
		#expect(result.configuration.point == nil)
	}

	@Test func makeSection_when_sectionIsCompletedAndMarked() {
		// Arrange
		let sut = ItemsFactory()

		let item = Item(
			uuid: .random,
			isDone: true,
			isMarked: true,
			text: .random,
			style: .section
		)

		// Act
		let result = sut.makeItem(item: item, level: 0, sectionStyle: .icon)

		// Assert
		#expect(result.isGroup)
		#expect(result.value.title == item.text)
		#expect(result.configuration.text.colorToken == .disabledText)
		#expect(result.configuration.text.strikethrough)
		#expect(result.configuration.point == nil)
	}
}

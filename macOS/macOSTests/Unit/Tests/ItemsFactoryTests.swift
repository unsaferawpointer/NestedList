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
		let result = sut.makeItem(item: item, level: 0)

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
		let result = sut.makeItem(item: item, level: 0)

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
		let result = sut.makeItem(item: item, level: 0)

		// Assert
		#expect(result.isGroup == false)
		#expect(result.value.title == item.text)
		#expect(result.value.subtitle == nil)
		#expect(result.configuration.text.colorToken == .disabledText)
		#expect(result.configuration.text.strikethrough)
		#expect(result.configuration.point?.color == .quaternary)
	}

	@Test func makeSection() {
		// Arrange
		let sut = ItemsFactory()

		let item = Item(
			uuid: .random,
			isDone: false,
			text: .random,
			style: .section
		)

		// Act
		let result = sut.makeItem(item: item, level: 0)

		// Assert
		#expect(result.isGroup)
		#expect(result.value.title == item.text)
		#expect(result.configuration.text.colorToken == .primary)
		#expect(!result.configuration.text.strikethrough)
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
		let result = sut.makeItem(item: item, level: 0)

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
		let result = sut.makeItem(item: item, level: 0)

		// Assert
		#expect(result.isGroup)
		#expect(result.value.title == item.text)
		#expect(result.configuration.text.colorToken == .disabledText)
		#expect(result.configuration.text.strikethrough)
		#expect(result.configuration.point == nil)
	}
}

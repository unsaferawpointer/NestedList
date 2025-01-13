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
			style: .item
		)

		// Act
		let result = sut.makeItem(item: item, isDone: false, level: 0)

		// Assert
		#expect(result.isGroup == false)
		#expect(result.value.text == item.text)
		#expect(result.configuration.textColor == .labelColor)
		#expect(!result.configuration.strikethrough)
		#expect(result.configuration.style == .point(.secondarySystemFill))
	}

	@Test func makeItem_when_itemIsCompleted() {
		// Arrange
		let sut = ItemsFactory()

		let item = Item(
			uuid: .random,
			isDone: false,
			text: .random,
			style: .item
		)

		// Act
		let result = sut.makeItem(item: item, isDone: true, level: 0)

		// Assert
		#expect(result.isGroup == false)
		#expect(result.value.text == item.text)
		#expect(result.configuration.textColor == .secondaryLabelColor)
		#expect(result.configuration.strikethrough)
		#expect(result.configuration.style == .point(.secondarySystemFill))
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
		let result = sut.makeItem(item: item, isDone: false, level: 0)

		// Assert
		#expect(result.isGroup)
		#expect(result.value.text == item.text)
		#expect(result.configuration.textColor == .labelColor)
		#expect(!result.configuration.strikethrough)
		#expect(result.configuration.style == .section)
	}

	@Test func makeSection_when_sectionIsCompleted() {
		// Arrange
		let sut = ItemsFactory()

		let item = Item(
			uuid: .random,
			isDone: false,
			text: .random,
			style: .section
		)

		// Act
		let result = sut.makeItem(item: item, isDone: true, level: 0)

		// Assert
		#expect(result.isGroup)
		#expect(result.value.text == item.text)
		#expect(result.configuration.textColor == .labelColor)
		#expect(result.configuration.strikethrough)
		#expect(result.configuration.style == .section)
	}
}

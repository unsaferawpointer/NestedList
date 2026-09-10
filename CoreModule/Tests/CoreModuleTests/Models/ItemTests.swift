//
//  ItemTests.swift
//  CoreModuleTests
//

import Foundation
import Testing
@testable import CoreModule

struct ItemTests { }

// MARK: - Initialization
extension ItemTests {

	@Test func initWithContentPreservesIdentifierAndContent() {
		// Arrange
		let uuid = UUID()
		let content = ItemContent(text: "Item")

		// Act
		let item = Item(id: uuid, content: content)

		// Assert
		#expect(item.id == uuid)
		#expect(item.content.id == uuid)
		#expect(item.content.content == content)
	}

	@Test func convenienceInitCreatesOriginalItem() {
		// Arrange
		let uuid = UUID()

		// Act
		let item = Item(uuid: uuid, text: "Item", view: .columns)

		// Assert
		#expect(item.id == uuid)
		#expect(item.content.id == uuid)
		#expect(item.content.content == ItemContent(text: "Item", view: .columns))
	}
}

// MARK: - ItemContent properties
extension ItemTests {

	@Test func storedPropertyProxiesReadContent() {
		// Arrange
		let uuid = UUID()
		let content = ItemContent(
			text: "Item",
			note: "Note",
			options: [.strikethrough],
			view: .columns,
			iconName: .document,
			tintColor: .blue
		)

		// Act
		let item = Item(id: uuid, content: content)

		// Assert
		#expect(item.uuid == uuid)
		#expect(item.text == content.text)
		#expect(item.note == content.note)
		#expect(item.options == content.options)
		#expect(item.view == content.view)
		#expect(item.iconName == content.iconName)
		#expect(item.tintColor == content.tintColor)
		#expect(item.isStrikethrough == content.isStrikethrough)
		#expect(item.isSubitemsHidden == content.isSubitemsHidden)
	}

	@Test func storedPropertyProxiesUpdateContent() {
		// Arrange
		let uuid = UUID()
		var item = Item(text: "Initial")

		// Act
		item.uuid = uuid
		item.text = "Updated"
		item.note = "Note"
		item.options = [.strikethrough]
		item.view = .columns
		item.iconName = .document
		item.tintColor = .blue

		// Assert
		#expect(item.id == uuid)
		#expect(item.content.text == "Updated")
		#expect(item.content.note == "Note")
		#expect(item.content.options == [.strikethrough])
		#expect(item.content.view == .columns)
		#expect(item.content.iconName == .document)
		#expect(item.content.tintColor == .blue)
	}

	@Test func computedPropertyProxiesUpdateContent() {
		// Arrange
		var item = Item(text: "Item", view: .columns)

		// Act
		item.properties = ItemProperties(text: "Updated", note: "Note")
		item.isStrikethrough = true
		item.isSubitemsHidden = true

		// Assert
		#expect(item.content.text == "Updated")
		#expect(item.content.note == "Note")
		#expect(item.content.isStrikethrough)
		#expect(item.content.isSubitemsHidden)
		#expect(item.content.view == .columns)
	}
}

// MARK: - Copying
extension ItemTests {

	@Test func copyReplacesIdentifierAndPreservesContent() {
		// Arrange
		let newId = UUID()
		let item = Item(text: "Item")

		// Act
		let copy = item.copy(with: newId)

		// Assert
		#expect(copy.uuid == newId)
		#expect(copy.content.id == newId)
		#expect(copy.content.content == item.content.content)
	}
}

// MARK: - Codable
extension ItemTests {

	@Test func codableUsesItemContentFormat() throws {
		// Arrange
		let item = Item(text: "Item", view: .columns)

		// Act
		let data = try JSONEncoder().encode(item)
		let object = try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])
		let decoded = try JSONDecoder().decode(Item.self, from: data)

		// Assert
		#expect(object["text"] as? String == "Item")
		#expect(object["uuid"] as? String == item.uuid.uuidString)
		#expect(object["content"] == nil)
		#expect(object["isMirror"] == nil)
		#expect(decoded.id == item.id)
		#expect(decoded.content == item.content)
	}
}

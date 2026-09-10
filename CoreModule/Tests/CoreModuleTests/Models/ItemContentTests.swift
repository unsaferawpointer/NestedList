//
//  ItemContentTests.swift
//  CoreModuleTests
//

import Foundation
import Testing
@testable import CoreModule

struct ItemContentTests { }

// MARK: - Item display view
extension ItemContentTests {

	@Test func defaultViewIsList() {
		// Arrange
		let item = ItemContent(text: "Item")

		// Act
		let view = item.view

		// Assert
		#expect(view == .list)
	}

	@Test func propertiesUpdatePreservesView() {
		// Arrange
		var item = ItemContent(text: "Item", view: .columns)

		// Act
		item.properties = .init(text: "Updated item")

		// Assert
		#expect(item.view == .columns)
	}

	@Test func itemViewRoundTripsThroughCodable() throws {
		// Arrange
		let item = ItemContent(text: "Item", view: .columns)

		// Act
		let data = try JSONEncoder().encode(item)
		let decoded = try JSONDecoder().decode(ItemContent.self, from: data)

		// Assert
		#expect(decoded.view == .columns)
	}

	@Test func missingItemViewDecodesAsList() throws {
		// Arrange
		let data = Data("""
	{
		\"text\": \"Item\",
		\"options\": 0
	}
	""".utf8)

		// Act
		let decoded = try JSONDecoder().decode(ItemContent.self, from: data)

		// Assert
		#expect(decoded.view == .list)
	}

	@Test func codableDoesNotContainIdentifier() throws {
		// Arrange
		let item = ItemContent(text: "Item")

		// Act
		let data = try JSONEncoder().encode(item)
		let object = try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])

		// Assert
		#expect(object["uuid"] == nil)
		#expect(object["id"] == nil)
	}
}

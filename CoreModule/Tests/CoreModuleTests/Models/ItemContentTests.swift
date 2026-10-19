//
//  ItemContentTests.swift
//  CoreModuleTests
//

import Foundation
import Testing
@testable import CoreModule

struct ItemContentTests { }

// MARK: - Codable
extension ItemContentTests {

	@Test func itemContentCodableDoesNotContainView() throws {
		// Arrange
		let item = ItemContent(text: "Item")

		// Act
		let data = try JSONEncoder().encode(item)
		let object = try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])

		// Assert
		#expect(object["view"] == nil)
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

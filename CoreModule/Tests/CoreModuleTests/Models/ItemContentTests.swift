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
		let item = ItemContent(text: "Item")

		#expect(item.view == .list)
	}

	@Test func copyPreservesView() {
		let item = ItemContent(text: "Item", view: .columns)

		#expect(item.copy().view == .columns)
	}

	@Test func propertiesUpdatePreservesView() {
		var item = ItemContent(text: "Item", view: .columns)
		item.properties = .init(text: "Updated item")

		#expect(item.view == .columns)
	}

	@Test func itemViewRoundTripsThroughCodable() throws {
		let item = ItemContent(text: "Item", view: .columns)

		let data = try JSONEncoder().encode(item)
		let decoded = try JSONDecoder().decode(ItemContent.self, from: data)

		#expect(decoded.view == .columns)
	}

	@Test func missingItemViewDecodesAsList() throws {
		let data = Data("""
	{
		\"uuid\": \"00000000-0000-0000-0000-000000000000\",
		\"text\": \"Item\",
		\"options\": 0
	}
	""".utf8)

		let decoded = try JSONDecoder().decode(ItemContent.self, from: data)

		#expect(decoded.view == .list)
	}
}

//
//  DocumentContentTests.swift
//  CoreModuleTests
//

import Foundation
import Testing
@testable import CoreModule

struct DocumentContentTests { }

// MARK: - Nested data structs
extension DocumentContentTests {

	@Test func contentViewInitializesFromKnownRawValues() {
		// Arrange
		let listRawValue = 0
		let columnsRawValue = 1

		// Act
		let list = DocumentContent.ContentView(rawValue: listRawValue)
		let columns = DocumentContent.ContentView(rawValue: columnsRawValue)

		// Assert
		#expect(list == .list)
		#expect(columns == .columns)
	}

	@Test func contentViewPreservesUnknownRawValue() {
		// Arrange
		let rawValue = 999

		// Act
		let view = DocumentContent.ContentView(rawValue: rawValue)

		// Assert
		#expect(view == .unknown(rawValue))
		#expect(view?.rawValue == rawValue)
	}

	@Test func unknownContentViewRoundTripsThroughCodable() throws {
		// Arrange
		let rawValue = 999
		let data = Data(String(rawValue).utf8)

		// Act
		let decodedView = try JSONDecoder().decode(DocumentContent.ContentView.self, from: data)
		let encodedData = try JSONEncoder().encode(decodedView)
		let encodedRawValue = try JSONDecoder().decode(Int.self, from: encodedData)

		// Assert
		#expect(decodedView == .unknown(rawValue))
		#expect(encodedRawValue == rawValue)
	}
}

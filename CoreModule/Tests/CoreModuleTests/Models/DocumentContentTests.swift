//
//  DocumentContentTests.swift
//  CoreModuleTests
//

import Foundation
import Testing
@testable import CoreModule

struct DocumentContentTests { }

// MARK: - Codable
extension DocumentContentTests {

	@Test func documentContentCodableDoesNotContainView() throws {
		// Arrange
		let content = DocumentContent(uuid: UUID())

		// Act
		let data = try JSONEncoder().encode(content)
		let object = try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])

		// Assert
		#expect(object["view"] == nil)
	}
}

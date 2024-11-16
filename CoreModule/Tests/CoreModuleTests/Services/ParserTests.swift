//
//  ParserTests.swift
//  TextParsing
//
//  Created by Anton Cherkasov on 16.11.2024.
//

import Testing
@testable import CoreModule

struct ParserTests {

	@Test func parseCanonicalText() {
		// Arrange
		let parser = Parser()
		let text =
		"""
		item 0
			item 0 0
			item 0 1
				item 0 1 0
		item 1
			item 1 0
			item 1 1
		"""

		// Act
		let result = parser.parse(from: text)

		// Assert
		check(result)
	}

	@Test func parseCanonicalText_whenBodyHasTabulation() {
		// Arrange
		let parser = Parser()
		let text =
		"""
		item 0
			item	 0 0
			item		 0 1
				item 0 1 0
		item 1
			item	 1 0
			item 1 1
		"""

		// Act
		let result = parser.parse(from: text)

		// Assert
		check(result)
	}

	@Test func parseShiftedText() {
		// Arrange
		let parser = Parser()
		let text =
		"""
			item 0
				item 0 0
				item 0 1
					item 0 1 0
			item 1
				item 1 0
				item 1 1
		"""

		// Act
		let result = parser.parse(from: text)

		// Assert
		check(result)
	}

	@Test func parseBrokenText() {
		// Arrange
		let parser = Parser()
		let text =
		"""
			item 0
					item 0 0
				item 0 1
						item 0 1 0
			item 1
				item 1 0
				item 1 1
		"""

		// Act
		let result = parser.parse(from: text)

		// Assert
		check(result)
	}

}

// MARK: - Helpers
private extension ParserTests {

	func check(_ result: [Node<Parser.Line>]) {
		#expect(result.count == 2)

		#expect(result[0].children.count == 2)
		#expect(result[0].children[0].children.count == 0)
		#expect(result[0].children[1].children.count == 1)
		#expect(result[0].children[1].children[0].children.count == 0)

		#expect(result[1].children.count == 2)
		#expect(result[1].children[0].children.count == 0)
		#expect(result[1].children[1].children.count == 0)
	}
}

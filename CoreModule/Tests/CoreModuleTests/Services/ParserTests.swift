//
//  ParserTests.swift
//  TextParsing
//
//  Created by Anton Cherkasov on 16.11.2024.
//

import Testing
import Foundation
import Hierarchy
@testable import CoreModule

struct ParserTests { }

// MARK: - testing ParserProtocol (v1.0.0)
extension ParserTests {

	@Test func parseCanonicalText() {
		test(file: "document-1-0-0")
	}

	@Test func parseCanonicalText_whenBodyHasTabulation() {
		test(file: "document-tabulation")
	}

	@Test func parseShiftedText() {
		test(file: "document-shifted")
	}

	@Test func parseBrokenText() {
		test(file: "document-broken")
	}

	@Test func format() {

		let sut = Parser()
		let text = load(file: "document-2-0-0")
		let nodes = sut.parse(from: text)

		// Act
		let document = nodes.map {
			sut.format($0)
		}.joined(separator: "\n")

		// Assert
		let reference = load(file: "reference").dropLast()
		#expect(reference.count == document.count)
		#expect(document == reference)
	}
}

// MARK: - testing ParserProtocol (v2.0.0)
extension ParserTests {

	@Test func parseCanonicalText_v2() {
		test(file: "document-2-0-0")
	}
}

// MARK: - Helpers
private extension ParserTests {

	func test(file name: String) {
		// Arrange
		let parser = Parser()
		let text = load(file: name)

		// Act
		let result = parser.parse(from: text)

		// Assert
		check(result)
	}

	func load(file: String) -> String {
		guard let text = FileLoader().loadFile(file) else {
			return ""
		}
		return text
	}

	func check(_ result: [Node<Item>]) {
		#expect(result.count == 2)

		// project 0
		let project0 = result[0]

		#expect(project0.value.style == .section(icon: nil))
		#expect(project0.value.text == "project 0")
		#expect(project0.value.isStrikethrough == false)
		#expect(project0.value.isMarked == false)
		#expect(project0.value.note == "Note 0")

		#expect(project0.children.count == 2)

		// item 00
		let item00 = project0.children[0]
		#expect(item00.value.isStrikethrough == false)
		#expect(item00.value.isMarked == true)
		#expect(item00.value.style == .item)
		#expect(item00.value.note == "Note 0 0")

		#expect(item00.children.count == 0)

		// item 01
		let item01 = project0.children[1]

		#expect(item01.value.isStrikethrough == false)
		#expect(item01.value.isMarked == false)
		#expect(item01.value.style == .item)
		#expect(item01.value.note == nil)

		#expect(item01.children.count == 1)

		// item 010
		let item010 = project0.children[1].children[0]

		#expect(item010.value.text == "item 0 1 0")
		#expect(item010.value.isStrikethrough == true)
		#expect(item010.value.isMarked == false)
		#expect(item010.value.style == .item)
		#expect(item010.value.note == "Note 0 1 0")

		#expect(item010.children.count == 0)

		// project 1

		let project1 = result[1]
		#expect(project1.value.style == .section(icon: nil))
		#expect(project1.value.text == "project 1")
		#expect(project1.value.isFolded)

		#expect(project1.children.count == 2)

		// item 10
		let item10 = project1.children[0]

		#expect(item10.value.isStrikethrough == false)
		#expect(item10.value.isMarked == false)
		#expect(item10.value.style == .item)
		#expect(item10.value.note == nil)

		#expect(item10.children.count == 0)

		// item 11
		let item11 = project1.children[1]

		#expect(item11.value.text == "item 1 1")
		#expect(item11.value.isStrikethrough == false)
		#expect(item11.value.isMarked == false)
		#expect(item11.value.style == .item)
		#expect(item11.value.note == nil)

		#expect(item11.children.count == 0)

	}
}

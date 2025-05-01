//
//  JsonDataProviderTests.swift
//  CoreModule
//
//  Created by Anton Cherkasov on 02.05.2025.
//

import XCTest
import Hierarchy
@testable import CoreModule

final class JsonDataProviderTests: XCTestCase {

	var sut: DataProvider!

	let type: DocumentType = .nlist

	override func setUpWithError() throws {
		sut = DataProvider()
	}

	override func tearDownWithError() throws {
		sut = nil
	}
}

// MARK: - ContentProvider interface testing (v1.0.0)
extension JsonDataProviderTests {

	func test_readFromDataOfType_whenV1_0_0() throws {
		// Arrange

		let expectedContent = Content(
			nodes:
				[
					Node<Item>(
						value: .init(
							uuid: .uuid0,
							text: "item 0",
							note: nil,
							options: [.section]
						),
						children:
							[
								Node<Item>(
									value: .init(
										uuid: .uuid00,
										text: "item 0 0",
										note: nil,
										options: []
									),
									children:
										[
											Node<Item>(
												value: .init(
													uuid: .uuid000,
													text: "item 0 0 0",
													note: "note 0 0 0",
													options: []
												)
											)
										]
								)
							]
					),
					Node<Item>(
						value: .init(
							uuid: .uuid1,
							text: "item 1",
							note: nil,
							options: [.strikethrough]
						)
					),
					Node<Item>(
						value: .init(
							uuid: .uuid2,
							text: "item 2",
							note: nil,
							options: [.strikethrough, .marked]
						)
					),
				]
		)

		let version = "1-0-0"

		let data = loadFile("document-\(version)")

		// Act
		let content = try sut.read(from: XCTUnwrap(data), ofType: type.rawValue)

		// Assert
		XCTAssertEqual(content, expectedContent)
	}

	func test_readFromDataOfType_whenVersionIsUnknown() throws {

		let version = "1-0-0"

		// Arrange
		let data = loadFile("document-unknown_version-\(version)")

		var isError = false

		do {
			// Act
			let _ = try sut.read(from: XCTUnwrap(data), ofType: type.rawValue)
		} catch let error as DocumentError where error == .unknownVersion {
			isError = true
		}

		// Assert
		XCTAssertTrue(isError)
	}

	func test_readFromDataOfType_whenFormatIsUnexpected() throws {

		let version = "1-0-0"

		// Arrange
		let data = loadFile("document-unexpected_format-\(version)")

		var isError = false

		// Act
		do {
			let _ = try sut.read(from: XCTUnwrap(data), ofType: type.rawValue)
		} catch let error as DocumentError where error == .unexpectedFormat {
			isError = true
		}

		// Assert
		XCTAssertTrue(isError)
	}
}

// MARK: - Helpers
private extension JsonDataProviderTests {

	func loadFile(_ name: String) -> Data? {
		return FileLoader().loadFile(name, fileExtension: "json")
	}

}

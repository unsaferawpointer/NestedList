//
//  JsonDataProviderTests.swift
//  CoreModule
//
//  Created by Anton Cherkasov on 02.05.2025.
//

import XCTest
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

		let expectedContent = DocumentContent(
			uuid: nil,
			nodes:
				[
					DocumentNode(
						value: .init(
							uuid: .uuid0,
							text: "item 0",
							note: nil,
							options: [],
							iconName: .document,
							tintColor: .secondary
						),
						children:
							[
								DocumentNode(
									value: .init(
										uuid: .uuid00,
										text: "item 0 0",
										note: nil,
										options: [],
										iconName: .unknown(999),
										tintColor: .unknown(999)
									),
									children:
										[
											DocumentNode(
												value: .init(
													uuid: .uuid000,
													text: "item 0 0 0",
													note: "note 0 0 0",
													options: []
												),
												children: []
											)
										]
								)
							]
					),
					DocumentNode(
						value: .init(
							uuid: .uuid1,
							text: "item 1",
							note: nil,
							options: [.strikethrough]
						),
						children: []
					),
					DocumentNode(
						value: .init(
							uuid: .uuid2,
							text: "item 2",
							note: nil,
							options: [.strikethrough, .marked]
						),
						children: []
					),
				],
			view: .columns
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

// MARK: - ContentProvider interface testing (v3.0.0)
extension JsonDataProviderTests {

	func test_readFromDataOfType_whenV3_0_0WithMirror() throws {
		// Arrange
		let data = try XCTUnwrap(loadFile("document-3-0-0"))
		let mirrorID = UUID(uuidString: "33333333-3333-3333-3333-333333333333")!
		let referenceID = UUID(uuidString: "22222222-2222-2222-2222-222222222222")!

		// Act
		let content = try sut.read(from: data, ofType: type.rawValue)

		// Assert
		XCTAssertEqual(content[mirrorID]?.id, mirrorID)
		XCTAssertTrue(content[mirrorID]?.isMirror == true)
		XCTAssertEqual(content[mirrorID]?.text, content[referenceID]?.text)
		XCTAssertEqual(content.snapshot().root, [
			UUID(uuidString: "11111111-1111-1111-1111-111111111111")!,
			mirrorID
		])
	}

	func test_dataOfType_whenContentReadFromV3_preservesMirrorReference() throws {
		// Arrange
		let sourceData = try XCTUnwrap(loadFile("document-3-0-0"))
		let content = try sut.read(from: sourceData, ofType: type.rawValue)

		// Act
		let data = try sut.data(ofType: type.rawValue, content: content)
		let object = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
		let version = try XCTUnwrap(object["version"] as? String)
		let fileContent = try XCTUnwrap(object["content"] as? [String: Any])
		let items = try XCTUnwrap(fileContent["items"] as? [[String: Any]])
		let value = try XCTUnwrap(items[1]["value"] as? [String: Any])
		let mirror = try XCTUnwrap(value["mirror"] as? [String: Any])

		// Assert
		XCTAssertEqual(version, "3.0.0")
		XCTAssertEqual(mirror["id"] as? String, "33333333-3333-3333-3333-333333333333")
		XCTAssertEqual(mirror["reference"] as? String, "22222222-2222-2222-2222-222222222222")
		XCTAssertNil(mirror["text"])
		XCTAssertNil(mirror["options"])
	}

	func test_readFromDataOfType_whenV3MirrorIsInvalid_throwsUnexpectedFormat() throws {
		// Arrange
		let names = [
			"document-missing-reference-3-0-0",
			"document-mirror-reference-3-0-0",
			"document-duplicate-identifier-3-0-0",
			"document-mirror-children-3-0-0"
		]

		// Act
		let results = names.map { name in
			guard let data = loadFile(name) else {
				return false
			}
			do {
				_ = try sut.read(from: data, ofType: type.rawValue)
				return false
			} catch let error as DocumentError {
				return error == .unexpectedFormat
			} catch {
				return false
			}
		}

		// Assert
		XCTAssertEqual(results, [true, true, true, true])
	}

	func test_dataOfType_whenContentReadFromLegacyFormat_writesV3() throws {
		// Arrange
		let sourceData = try XCTUnwrap(loadFile("document-2-0-0"))
		let content = try sut.read(from: sourceData, ofType: type.rawValue)

		// Act
		let data = try sut.data(ofType: type.rawValue, content: content)
		let object = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])

		// Assert
		XCTAssertEqual(object["version"] as? String, "3.0.0")
	}
}

// MARK: - ContentProvider interface testing (v2.0.0)
extension JsonDataProviderTests {

	func test_readFromDataOfType_whenV2_0_0() throws {
		// Arrange

		let expectedContent = DocumentContent(
			uuid: nil,
			nodes:
				[
					DocumentNode(
						value: .init(
							uuid: .uuid0,
							text: "item 0",
							note: nil,
							options: [],
							iconName: .document,
							tintColor: .secondary
						),
						children:
							[
								DocumentNode(
									value: .init(
										uuid: .uuid00,
										text: "item 0 0",
										note: nil,
										options: [],
										iconName: .unknown(999),
										tintColor: .unknown(999)
									),
									children:
										[
											DocumentNode(
												value: .init(
													uuid: .uuid000,
													text: "item 0 0 0",
													note: "note 0 0 0",
													options: []
												),
												children: []
											)
										]
								)
							]
					),
					DocumentNode(
						value: .init(
							uuid: .uuid1,
							text: "item 1",
							note: nil,
							options: [.strikethrough]
						),
						children: []
					),
					DocumentNode(
						value: .init(
							uuid: .uuid2,
							text: "item 2",
							note: nil,
							options: [.strikethrough, .marked]
						),
						children: []
					),
				],
			view: .columns
		)

		let version = "2-0-0"

		let data = loadFile("document-\(version)")

		// Act
		let content = try sut.read(from: XCTUnwrap(data), ofType: type.rawValue)

		// Assert
		XCTAssertEqual(content, expectedContent)
	}
}

// MARK: - Helpers
private extension JsonDataProviderTests {

	func loadFile(_ name: String) -> Data? {
		return FileLoader().loadFile(name, fileExtension: "json")
	}

}

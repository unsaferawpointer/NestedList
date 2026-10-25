//
//  DocumentContentTests.swift
//  CoreModuleTests
//

import Foundation
import Hierarchy
import Testing
@testable import CoreModule

struct DocumentContentTests { }

// MARK: - File representation
extension DocumentContentTests {

	@Test func exportPreservesStoredHierarchyAndMirrorReferences() throws {
		// Arrange
		let fixture = Fixture()
		let content = fixture.content
		let mirrorID = try content.insertMirror(reference: fixture.child.id, to: .inRoot(atIndex: 1))

		// Act
		let dto = content.exportContent()

		// Assert
		#expect(dto.uuid == fixture.uuid)
		#expect(dto.items.map(\.id) == [fixture.parent.id, mirrorID, fixture.sibling.id])
		#expect(dto.items[0].value == .item(id: fixture.parent.id, content: fixture.parent.content))
		#expect(dto.items[0].children.map(\.id) == [fixture.child.id])
		#expect(dto.items[0].children[0].value == .item(id: fixture.child.id, content: fixture.child.content))
		#expect(dto.items[1].value == .mirror(id: mirrorID, reference: fixture.child.id))
		#expect(dto.items[1].children.isEmpty)
		#expect(dto.items[2].value == .item(id: fixture.sibling.id, content: fixture.sibling.content))
	}

	@Test func exportedDTOIsIndependentOfWorkingTreeChanges() throws {
		// Arrange
		let fixture = Fixture()
		let content = fixture.content
		let dto = content.exportContent()

		// Act
		content.setProperty(\.text, to: "Changed", for: [fixture.child.id])
		try content.moveItems(with: [fixture.child.id], to: .toRoot)
		content.deleteItems([fixture.sibling.id])

		// Assert
		#expect(dto.items.map(\.id) == [fixture.parent.id, fixture.sibling.id])
		#expect(dto.items[0].children.map(\.id) == [fixture.child.id])
		#expect(dto.items[0].children[0].value == .item(id: fixture.child.id, content: fixture.child.content))
	}

	@Test func changingDTOCopyDoesNotChangeOriginalDTOOrWorkingTree() {
		// Arrange
		let fixture = Fixture()
		let content = fixture.content
		let dto = content.exportContent()
		var copy = dto

		// Act
		copy.uuid = nil
		copy.items[0].children[0].value = .item(id: fixture.child.id, content: ItemContent(text: "Changed"))
		copy.items.removeLast()

		// Assert
		#expect(dto.uuid == fixture.uuid)
		#expect(dto.items.map(\.id) == [fixture.parent.id, fixture.sibling.id])
		#expect(dto.items[0].children[0].value == .item(id: fixture.child.id, content: fixture.child.content))
		#expect(content[fixture.child.id] == fixture.child)
		#expect(content[fixture.sibling.id] == fixture.sibling)
	}

	@Test func restoredTreesAreIndependentAndPreserveMirrorBehavior() throws {
		// Arrange
		let fixture = Fixture()
		let original = fixture.content
		let mirrorID = try original.insertMirror(reference: fixture.child.id, to: .toRoot)
		let dto = original.exportContent()
		let restored = try DocumentContent(dto: dto)
		let another = try DocumentContent(dto: dto)

		// Act
		restored.setProperty(\.text, to: "Changed", for: [mirrorID])
		try restored.moveItems(with: [fixture.child.id], to: .toRoot)

		// Assert
		#expect(restored.uuid == fixture.uuid)
		#expect(restored[fixture.child.id]?.text == "Changed")
		#expect(restored[mirrorID]?.text == "Changed")
		#expect(restored[mirrorID]?.isMirror == true)
		#expect(original[fixture.child.id] == fixture.child)
		#expect(another[fixture.child.id] == fixture.child)
		#expect(another[mirrorID]?.text == fixture.child.text)
		#expect(original.parent(for: fixture.child.id) == fixture.parent.id)
		#expect(another.parent(for: fixture.child.id) == fixture.parent.id)
		#expect(dto.items[0].children[0].value == .item(id: fixture.child.id, content: fixture.child.content))
	}

	@Test func conversionPreservesMissingDocumentIdentifier() throws {
		// Arrange
		let content = DocumentContent(uuid: nil)

		// Act
		let dto = content.exportContent()
		let restored = try DocumentContent(dto: dto)

		// Assert
		#expect(dto.uuid == nil)
		#expect(dto.items.isEmpty)
		#expect(restored.uuid == nil)
		#expect(restored.snapshot().count == 0)
	}

	@Test func restoringDTORejectsMissingMirrorReference() {
		// Arrange
		let dto = DocumentContentDTO(
			uuid: UUID(),
			items: [DocumentNode(value: .mirror(id: UUID(), reference: UUID()), children: [])]
		)

		// Act
		let error = #expect(throws: MirrorStoreError.self) {
			try DocumentContent(dto: dto)
		}

		// Assert
		guard case .missingReference = error else {
			Issue.record("Expected a missing mirror reference error")
			return
		}
	}
}

// MARK: - File representation Codable
extension DocumentContentTests {

	@Test func dtoCodablePreservesStoredContainers() throws {
		// Arrange
		let fixture = Fixture()
		let content = fixture.content
		let mirrorID = try content.insertMirror(reference: fixture.child.id, to: .toRoot)
		let dto = content.exportContent()

		// Act
		let data = try JSONEncoder().encode(dto)
		let decoded = try JSONDecoder().decode(DocumentContentDTO.self, from: data)
		let restored = try DocumentContent(dto: decoded)
		let object = try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])
		let items = try #require(object["items"] as? [[String: Any]])
		let value = try #require(items.last?["value"] as? [String: Any])
		let mirror = try #require(value["mirror"] as? [String: Any])

		// Assert
		#expect(restored == content)
		#expect(Set(object.keys) == ["uuid", "items"])
		#expect(Set(mirror.keys) == ["id", "reference"])
		#expect(mirror["id"] as? String == mirrorID.uuidString)
		#expect(mirror["reference"] as? String == fixture.child.id.uuidString)
	}

	@Test func documentContentEncodingMatchesDTOEncoding() throws {
		// Arrange
		let content = Fixture().content
		let encoder = JSONEncoder()
		encoder.outputFormatting = .sortedKeys

		// Act
		let contentData = try encoder.encode(content)
		let dtoData = try encoder.encode(content.exportContent())

		// Assert
		#expect(contentData == dtoData)
	}
}

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

// MARK: - Nested data structs
private extension DocumentContentTests {

	struct Fixture {

		let uuid = UUID()
		let parent = Item(text: "Parent", note: "Parent note", options: [.strikethrough], iconName: .document, tintColor: .yellow)
		let child = Item(text: "Child", note: "Child note")
		let sibling = Item(text: "Sibling")

		var content: DocumentContent {
			DocumentContent(
				uuid: uuid,
				nodes: [
					DocumentNode(value: parent, children: [DocumentNode(value: child, children: [])]),
					DocumentNode(value: sibling, children: [])
				]
			)
		}
	}
}

//
//  DocumentRepositoryTests.swift
//  CoreModuleTests
//

import Foundation
import Hierarchy
import Testing
@testable import CoreModule

struct DocumentRepositoryTests { }

// MARK: - Initialization
extension DocumentRepositoryTests {

	@Test func newRepositoriesHaveUniqueIdentifiersAndEmptyTrees() {
		// Arrange
		let first = DocumentRepository()
		let second = DocumentRepository()

		// Act
		let content = first.exportContent()

		// Assert
		#expect(first.uuid != nil)
		#expect(first.uuid != second.uuid)
		#expect(content.uuid == first.uuid)
		#expect(content.items.isEmpty)
		#expect(first.snapshot().count == 0)
	}

	@Test func initializationRestoresHierarchyAndForwardMirrorReferences() throws {
		// Arrange
		let fixture = Fixture()
		var dto = fixture.dto
		dto.items.swapAt(0, 1)

		// Act
		let repository = try DocumentRepository(dto: dto)

		// Assert
		#expect(repository.uuid == fixture.uuid)
		#expect(repository.snapshot().root == [fixture.mirrorID, fixture.parent.id, fixture.sibling.id])
		#expect(repository.parent(for: fixture.child.id) == fixture.parent.id)
		#expect(repository[fixture.child.id] == fixture.child)
		#expect(repository[fixture.mirrorID]?.isMirror == true)
		#expect(repository[fixture.mirrorID]?.content == fixture.child.content)
	}

	@Test func initializationPreservesMissingDocumentIdentifier() throws {
		// Arrange
		let dto = DocumentContentDTO(uuid: nil)

		// Act
		let repository = try DocumentRepository(dto: dto)

		// Assert
		#expect(repository.uuid == nil)
		#expect(repository.exportContent().uuid == nil)
	}

	@Test(arguments: InvalidHierarchy.allCases)
	func initializationRejectsInvalidHierarchy(_ hierarchy: InvalidHierarchy) {
		// Arrange
		let dto = hierarchy.dto

		// Act
		let error = #expect(throws: MirrorStoreError.self) {
			try DocumentRepository(dto: dto)
		}

		// Assert
		#expect(error != nil)
	}
}

// MARK: - File representation
extension DocumentRepositoryTests {

	@Test func exportPreservesContainersAndIsIndependentOfSubsequentEdits() throws {
		// Arrange
		let fixture = Fixture()
		let repository = try DocumentRepository(dto: fixture.dto)
		let dto = repository.exportContent()

		// Act
		repository.setProperty(\.text, to: "Changed", for: [fixture.child.id])
		try repository.moveItems(with: [fixture.child.id], to: .toRoot)
		repository.deleteItems([fixture.sibling.id])

		// Assert
		#expect(dto.uuid == fixture.uuid)
		#expect(dto.items.map(\.id) == [fixture.parent.id, fixture.mirrorID, fixture.sibling.id])
		#expect(dto.items[0].value == .item(id: fixture.parent.id, content: fixture.parent.content))
		#expect(dto.items[0].children[0].value == .item(id: fixture.child.id, content: fixture.child.content))
		#expect(dto.items[1].value == .mirror(id: fixture.mirrorID, reference: fixture.child.id))
		#expect(dto.items[1].children.isEmpty)
	}

	@Test func repositoriesImportedFromTheSameDTOAreIndependent() throws {
		// Arrange
		let fixture = Fixture()
		let dto = fixture.dto
		let first = try DocumentRepository(dto: dto)
		let second = try DocumentRepository(dto: dto)

		// Act
		first.setProperty(\.text, to: "Changed", for: [fixture.mirrorID])
		try first.moveItems(with: [fixture.child.id], to: .toRoot)

		// Assert
		#expect(first[fixture.child.id]?.text == "Changed")
		#expect(second[fixture.child.id] == fixture.child)
		#expect(second[fixture.mirrorID]?.content == fixture.child.content)
		#expect(second.parent(for: fixture.child.id) == fixture.parent.id)
		#expect(dto.items[0].children[0].value == .item(id: fixture.child.id, content: fixture.child.content))
	}

	@Test func replacementUpdatesExistingReferencesAndKeepsSnapshotsIndependent() throws {
		// Arrange
		let oldFixture = Fixture()
		let newFixture = Fixture()
		let repository = try DocumentRepository(dto: oldFixture.dto)
		let reference = repository
		let snapshot = repository.snapshot()

		// Act
		try repository.replaceContent(newFixture.dto)

		// Assert
		#expect(reference.uuid == newFixture.uuid)
		#expect(reference[oldFixture.parent.id] == nil)
		#expect(reference[newFixture.child.id] == newFixture.child)
		#expect(reference[newFixture.mirrorID]?.content == newFixture.child.content)
		#expect(reference.snapshot().root == [newFixture.parent.id, newFixture.mirrorID, newFixture.sibling.id])
		#expect(snapshot.root == [oldFixture.parent.id, oldFixture.mirrorID, oldFixture.sibling.id])
		#expect(snapshot.model(with: oldFixture.child.id) == oldFixture.child)
	}

	@Test func replacementDoesNotShareWorkingTreeWithAnotherRepository() throws {
		// Arrange
		let fixture = Fixture()
		let source = try DocumentRepository(dto: fixture.dto)
		let repository = DocumentRepository()

		// Act
		try repository.replaceContent(source.exportContent())
		source.setProperty(\.note, to: "Changed", for: [fixture.child.id])
		repository.deleteItems([fixture.sibling.id])

		// Assert
		#expect(repository[fixture.child.id] == fixture.child)
		#expect(repository[fixture.mirrorID]?.note == fixture.child.note)
		#expect(source[fixture.sibling.id] == fixture.sibling)
	}

	@Test(arguments: InvalidHierarchy.allCases)
	func failedReplacementPreservesDocumentIdentifierAndEntireTree(_ hierarchy: InvalidHierarchy) throws {
		// Arrange
		let repository = try DocumentRepository(dto: Fixture().dto)
		let encoder = JSONEncoder()
		encoder.outputFormatting = .sortedKeys
		let before = try encoder.encode(repository.exportContent())

		// Act
		#expect(throws: MirrorStoreError.self) {
			try repository.replaceContent(hierarchy.dto)
		}
		let after = try encoder.encode(repository.exportContent())

		// Assert
		#expect(after == before)
	}

	@Test func replacementWithEmptyContentClearsTreeAndDocumentIdentifier() throws {
		// Arrange
		let repository = try DocumentRepository(dto: Fixture().dto)

		// Act
		try repository.replaceContent(DocumentContentDTO(uuid: nil))

		// Assert
		#expect(repository.uuid == nil)
		#expect(repository.snapshot().count == 0)
		#expect(repository.exportContent().items.isEmpty)
	}
}

// MARK: - Reading and validation
extension DocumentRepositoryTests {

	@Test func returnedNodesAndSnapshotsAreIndependentOfLaterEdits() throws {
		// Arrange
		let fixture = Fixture()
		let repository = try DocumentRepository(dto: fixture.dto)
		let node = try #require(repository.node(with: fixture.parent.id))
		let tree = repository.tree()
		let snapshot = repository.snapshot()

		// Act
		repository.setProperty(\.text, to: "Changed", for: [fixture.child.id])
		repository.deleteItems([fixture.parent.id])

		// Assert
		#expect(node.children[0].value == fixture.child)
		#expect(tree[0].children[0].value == fixture.child)
		#expect(snapshot.model(with: fixture.child.id) == fixture.child)
		#expect(repository[fixture.child.id] == nil)
	}

	@Test func validationRejectsMovingParentIntoDescendantAndMirrorsIntoCycle() throws {
		// Arrange
		let fixture = Fixture()
		let repository = try DocumentRepository(dto: fixture.dto)

		// Act
		let canMove = repository.validateMoving([fixture.parent.id], to: .onItem(with: fixture.child.id))
		let invalidTargets = repository.invalidTargets(movingItems: [fixture.parent.id])
		let sourceIDs = repository.mirrorSourceIDs(to: .onItem(with: fixture.child.id))

		// Assert
		#expect(!canMove)
		#expect(invalidTargets == [fixture.parent.id, fixture.child.id])
		#expect(sourceIDs == [fixture.sibling.id])
		#expect(repository.parent(for: nil) == nil)
		#expect(repository.parent(for: fixture.child.id) == fixture.parent.id)
	}
}

// MARK: - Editing
extension DocumentRepositoryTests {

	@Test func editingThroughMirrorUpdatesOriginalAndOtherMirrors() throws {
		// Arrange
		let fixture = Fixture()
		let repository = try DocumentRepository(dto: fixture.dto)
		let anotherMirrorID = try repository.insertMirror(reference: fixture.mirrorID, to: .toRoot)

		// Act
		repository.setProperty(\.text, to: "Changed", for: [fixture.mirrorID])

		// Assert
		#expect(repository[fixture.child.id]?.text == "Changed")
		#expect(repository[anotherMirrorID]?.text == "Changed")
		#expect(repository.exportContent().items.last?.value == .mirror(id: anotherMirrorID, reference: fixture.child.id))
	}

	@Test func deletingOriginalSubtreeRemovesDependentMirrors() throws {
		// Arrange
		let fixture = Fixture()
		let repository = try DocumentRepository(dto: fixture.dto)

		// Act
		repository.deleteItems([fixture.parent.id])

		// Assert
		#expect(repository[fixture.child.id] == nil)
		#expect(repository[fixture.mirrorID] == nil)
		#expect(repository.snapshot().root == [fixture.sibling.id])
	}

	@Test func insertionAndDownstreamEditingPreserveNestedContent() throws {
		// Arrange
		let fixture = Fixture()
		let repository = DocumentRepository()
		let child = DocumentNode(value: fixture.child, children: [])
		let parent = DocumentNode(value: fixture.parent, children: [child])

		// Act
		try repository.insertItems(from: [parent], to: .toRoot)
		try repository.insertItems(with: [fixture.sibling], to: .onItem(with: fixture.parent.id))
		repository.setProperty(\.isStrikethrough, to: true, for: [fixture.parent.id], downstream: true)

		// Assert
		#expect(repository.snapshot().children(of: fixture.parent.id).map(\.id) == [fixture.child.id, fixture.sibling.id])
		#expect(repository[fixture.child.id]?.note == fixture.child.note)
		#expect(repository[fixture.sibling.id]?.isStrikethrough == true)
		#expect(repository.allMatch(id: fixture.parent.id, keyPath: \.isStrikethrough, equalsTo: true))
	}

	@Test func copyingSubtreeCreatesIndependentItemsWithNewIdentifiers() throws {
		// Arrange
		let fixture = Fixture()
		let repository = try DocumentRepository(dto: fixture.dto)

		// Act
		try repository.copy(ids: [fixture.parent.id], to: .toRoot)
		let copied = try #require(repository.exportContent().items.last)
		let copiedChild = try #require(copied.children.first)
		repository.setProperty(\.text, to: "Changed", for: [copiedChild.id])

		// Assert
		#expect(copied.id != fixture.parent.id)
		#expect(copiedChild.id != fixture.child.id)
		#expect(repository[copied.id]?.content == fixture.parent.content)
		#expect(repository[copiedChild.id]?.text == "Changed")
		#expect(repository[fixture.child.id] == fixture.child)
		#expect(repository[fixture.mirrorID]?.content == fixture.child.content)
	}
}

// MARK: - Nested data structs
extension DocumentRepositoryTests {

	struct Fixture {

		let uuid = UUID()
		let parent = Item(text: "Parent", note: "Parent note", iconName: .document, tintColor: .yellow)
		let child = Item(text: "Child", note: "Child note")
		let sibling = Item(text: "Sibling")
		let mirrorID = UUID()

		var dto: DocumentContentDTO {
			DocumentContentDTO(
				uuid: uuid,
				items: [
					DocumentNode(
						value: .item(id: parent.id, content: parent.content),
						children: [DocumentNode(value: .item(id: child.id, content: child.content), children: [])]
					),
					DocumentNode(value: .mirror(id: mirrorID, reference: child.id), children: []),
					DocumentNode(value: .item(id: sibling.id, content: sibling.content), children: [])
				]
			)
		}
	}

	enum InvalidHierarchy: CaseIterable {

		case missingReference
		case referenceToMirror
		case duplicateIdentifier
		case mirrorWithChildren
		case referenceCycle

		var dto: DocumentContentDTO {
			let fixture = Fixture()
			var dto = fixture.dto
			switch self {
			case .missingReference:
				dto.items[1].value = .mirror(id: fixture.mirrorID, reference: UUID())
			case .referenceToMirror:
				dto.items.append(DocumentNode(value: .mirror(id: UUID(), reference: fixture.mirrorID), children: []))
			case .duplicateIdentifier:
				dto.items.append(dto.items[0])
			case .mirrorWithChildren:
				dto.items[1].children = [DocumentNode(value: .item(id: UUID(), content: ItemContent(text: "Invalid child")), children: [])]
			case .referenceCycle:
				dto.items[0].children.append(DocumentNode(value: .mirror(id: UUID(), reference: fixture.parent.id), children: []))
			}
			return dto
		}
	}
}

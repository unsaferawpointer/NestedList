import Testing
import Foundation
import CoreModule
import Hierarchy
@testable import iOS

@MainActor
struct ContentUnitInteractorTests { }

// MARK: - Focus navigation
extension ContentUnitInteractorTests {

	@Test func focus_buildsAncestorPathAndKeepsStateLocalToPresentation() {
		// Arrange
		let fixture = Fixture()
		let sut = ContentUnitInteractor(root: nil, storage: fixture.storage)
		let other = ContentUnitInteractor(root: nil, storage: fixture.storage)

		// Act
		let (_, snapshot) = sut.focus(on: fixture.child.id)

		// Assert
		#expect(snapshot.identifiers == [fixture.leaf.id])
		#expect(sut.pathItems().map { $0?.id } == [nil, fixture.parent.id, fixture.child.id])
		#expect(other.pathItems().count == 1)
		#expect(other.fetchData().1.count == 4)
	}

	@Test func focus_onAncestorAndDocumentRestoresTheirChildren() {
		// Arrange
		let fixture = Fixture()
		let sut = ContentUnitInteractor(root: nil, storage: fixture.storage)
		_ = sut.focus(on: fixture.child.id)

		// Act
		let (_, ancestorSnapshot) = sut.focus(on: fixture.parent.id)
		let ancestorPath = sut.pathItems()
		let (_, documentSnapshot) = sut.focus(on: nil)

		// Assert
		#expect(ancestorSnapshot.identifiers == [fixture.child.id, fixture.leaf.id])
		#expect(ancestorPath.map { $0?.id } == [nil, fixture.parent.id])
		#expect(documentSnapshot.count == 4)
		#expect(sut.pathItems().map { $0?.id } == [nil])
	}

	@Test func focus_preservesInitialScopeAndRejectsOutsideTargets() {
		// Arrange
		let fixture = Fixture()
		let sut = ContentUnitInteractor(root: fixture.parent.id, storage: fixture.storage)
		_ = sut.focus(on: fixture.child.id)

		// Act
		_ = sut.focus(on: fixture.other.id)
		let path = sut.pathItems()
		let (_, snapshot) = sut.focus(on: nil)

		// Assert
		#expect(path.map { $0?.id } == [fixture.parent.id, fixture.child.id])
		#expect(snapshot.identifiers == [fixture.child.id, fixture.leaf.id])
		#expect(sut.pathItems().map { $0?.id } == [fixture.parent.id])
	}

	@Test func focus_rejectsMirrorsAndMissingItems() throws {
		// Arrange
		let fixture = Fixture()
		var mirrorID: UUID!
		try fixture.storage.modificate { content in
			mirrorID = try content.insertMirror(reference: fixture.child.id, to: .toRoot)
		}
		let sut = ContentUnitInteractor(root: nil, storage: fixture.storage)
		_ = sut.focus(on: fixture.parent.id)

		// Act
		_ = sut.focus(on: mirrorID)
		_ = sut.focus(on: UUID())

		// Assert
		#expect(sut.pathItems().map { $0?.id } == [nil, fixture.parent.id])
	}

	@Test func focus_onLeafKeepsNavigationPathAvailable() {
		// Arrange
		let fixture = Fixture()
		let sut = ContentUnitInteractor(root: nil, storage: fixture.storage)

		// Act
		let (_, snapshot) = sut.focus(on: fixture.leaf.id)

		// Assert
		#expect(snapshot.count == 0)
		#expect(sut.pathItems().map { $0?.id } == [nil, fixture.parent.id, fixture.child.id, fixture.leaf.id])
	}
}

// MARK: - Storage changes and editing
extension ContentUnitInteractorTests {

	@Test func deletingFocusedItemRestoresDeepestExistingAncestor() {
		// Arrange
		let fixture = Fixture()
		let sut = ContentUnitInteractor(root: nil, storage: fixture.storage)
		_ = sut.focus(on: fixture.child.id)

		// Act
		fixture.storage.modificate { $0.deleteItems([fixture.child.id]) }
		let (_, snapshot) = sut.fetchData()

		// Assert
		#expect(snapshot.count == 0)
		#expect(sut.pathItems().map { $0?.id } == [nil, fixture.parent.id])
	}

	@Test func movingFocusedItemRestoresLastValidPathComponent() throws {
		// Arrange
		let fixture = Fixture()
		let sut = ContentUnitInteractor(root: nil, storage: fixture.storage)
		_ = sut.focus(on: fixture.child.id)

		// Act
		try fixture.storage.modificate { content in
			try content.moveItems(with: [fixture.child.id], to: .onItem(with: fixture.other.id))
		}
		_ = sut.fetchData()

		// Assert
		#expect(sut.pathItems().map { $0?.id } == [nil, fixture.parent.id])
	}

	@Test func editingUsesFocusedRootAndUpdatesFocusedSnapshot() throws {
		// Arrange
		let fixture = Fixture()
		let sut = ContentUnitInteractor(root: nil, storage: fixture.storage)
		_ = sut.focus(on: fixture.child.id)

		// Act
		let newID = try sut.newItem(with: ItemProperties(text: "New"), target: nil)
		sut.insertStrings(["Pasted"], to: .toRoot)
		sut.move(ids: [fixture.other.id], to: .toRoot)
		let (_, snapshot) = sut.fetchData()

		// Assert
		#expect(fixture.storage.state.parent(for: newID) == fixture.child.id)
		#expect(fixture.storage.state.parent(for: fixture.other.id) == fixture.child.id)
		#expect(snapshot.count == 4)
		#expect(snapshot.identifiers.contains(newID))
		#expect(snapshot.identifiers.contains(fixture.other.id))
	}
}

// MARK: - Nested data structs
private extension ContentUnitInteractorTests {

	struct Fixture {
		let parent = Item(text: "Parent")
		let child = Item(text: "Child")
		let leaf = Item(text: "Leaf")
		let other = Item(text: "Other")
		let storage: DocumentStorage<DocumentContent>

		init() {
			storage = DocumentStorage(
				stateProvider: StateProvider(initialState: DocumentContent(uuid: nil, nodes: [
					DocumentNode(value: parent, children: [
						DocumentNode(value: child, children: [DocumentNode(value: leaf, children: [])])
					]),
					DocumentNode(value: other, children: [])
				])),
				contentProvider: DataProvider(),
				undoManager: nil
			)
		}
	}
}

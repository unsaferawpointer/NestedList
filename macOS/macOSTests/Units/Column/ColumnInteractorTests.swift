import CoreModule
import Foundation
import Hierarchy
import Testing
@testable import Nested_List

@MainActor
struct ColumnInteractorTests {

	@Test func appearanceOperations_updateOnlyColumnRoot() {
		let root = Item(uuid: UUID(), text: "Column")
		let child = Item(uuid: UUID(), text: "Child")
		let storage = makeStorage(root: root, child: child)
		let sut = ColumnInteractor(root: root.id, storage: storage)

		sut.setIcon(.bolt)
		sut.setColor(.cyan)

		#expect(storage.state[root.id]?.iconName == .bolt)
		#expect(storage.state[root.id]?.tintColor == .cyan)
		#expect(storage.state[child.id]?.iconName == nil)
		#expect(storage.state[child.id]?.tintColor == nil)
	}

	@Test func toggleStrikethrough_updatesColumnAndDescendants() {
		let root = Item(uuid: UUID(), text: "Column")
		let child = Item(uuid: UUID(), text: "Child")
		let storage = makeStorage(root: root, child: child)
		let sut = ColumnInteractor(root: root.id, storage: storage)

		sut.toggleStrikethrough(moveToEnd: false)

		#expect(sut.isStrikethrough())
		#expect(storage.state[root.id]?.isStrikethrough == true)
		#expect(storage.state[child.id]?.isStrikethrough == true)
	}
}

private extension ColumnInteractorTests {

	func makeStorage(root: Item, child: Item) -> DocumentStorage<DocumentContent> {
		let storage = DocumentStorage(
			stateProvider: StateProvider(initialState: DocumentContent.empty),
			contentProvider: JsonDataProvider(),
			undoManager: nil
		)
		storage.modificate { content in
			content.insertItems(with: [root], to: .toRoot)
			content.insertItems(with: [child], to: .onItem(with: root.id))
		}
		return storage
	}
}

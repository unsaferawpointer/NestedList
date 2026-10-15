import Testing
import Foundation
import CoreModule

@testable import Nested_List

struct NavigationResolverTests {}

// MARK: - resolve test-cases
extension NavigationResolverTests {

	@Test func resolve_preservesPathWhenItMatchesActualChain() throws {
		// Arrange
		let documentRoot = Item(text: "Document root")
		let initialRoot = Item(text: "Initial root")
		let parent = Item(text: "Parent")
		let target = Item(text: "Target")
		let path = NavigationPath(root: initialRoot.id, suffix: [parent.id, target.id])
		let sut = NavigationResolver(path: path)
		let content = DocumentContent(
			uuid: nil,
			nodes: [
				DocumentNode(
					value: documentRoot,
					children: [
						DocumentNode(
							value: initialRoot,
							children: [
								DocumentNode(
									value: parent,
									children: [DocumentNode(value: target, children: [])]
								)
							]
						)
					]
				)
			]
		)

		// Act
		try sut.resolve(content: content)

		// Assert
		#expect(sut.path.root == initialRoot.id)
		#expect(sut.path.suffix == [parent.id, target.id])
		#expect(sut.path.focused == target.id)
	}

	@Test func resolve_restoresDeepestExistingPathItemAfterDeletion() throws {
		// Arrange
		let documentRoot = Item(text: "Document root")
		let initialRoot = Item(text: "Initial root")
		let parent = Item(text: "Parent")
		let target = UUID()
		let path = NavigationPath(root: initialRoot.id, suffix: [parent.id, target])
		let sut = NavigationResolver(path: path)
		let content = DocumentContent(
			uuid: nil,
			nodes: [
				DocumentNode(
					value: documentRoot,
					children: [
						DocumentNode(
							value: initialRoot,
							children: [DocumentNode(value: parent, children: [])]
						)
					]
				)
			]
		)

		// Act
		try sut.resolve(content: content)

		// Assert
		#expect(sut.path.root == initialRoot.id)
		#expect(sut.path.suffix == [parent.id])
		#expect(sut.path.focused == parent.id)
	}

	@Test func resolve_restoresLastCommonPathItemAfterMove() throws {
		// Arrange
		let documentRoot = Item(text: "Document root")
		let initialRoot = Item(text: "Initial root")
		let previousParent = Item(text: "Previous parent")
		let newParent = Item(text: "New parent")
		let target = Item(text: "Target")
		let path = NavigationPath(root: initialRoot.id, suffix: [previousParent.id, target.id])
		let sut = NavigationResolver(path: path)
		let content = DocumentContent(
			uuid: nil,
			nodes: [
				DocumentNode(
					value: documentRoot,
					children: [
						DocumentNode(
							value: initialRoot,
							children: [
								DocumentNode(value: previousParent, children: []),
								DocumentNode(
									value: newParent,
									children: [DocumentNode(value: target, children: [])]
								)
							]
						)
					]
				)
			]
		)

		// Act
		try sut.resolve(content: content)

		// Assert
		#expect(sut.path.root == initialRoot.id)
		#expect(sut.path.suffix == [previousParent.id])
		#expect(sut.path.focused == previousParent.id)
	}

	@Test func resolve_throwsWhenInitialRootDoesNotExist() {
		// Arrange
		let initialRoot = UUID()
		let parent = Item(text: "Parent")
		let target = Item(text: "Target")
		let path = NavigationPath(root: initialRoot, suffix: [parent.id, target.id])
		let sut = NavigationResolver(path: path)
		let content = DocumentContent(
			uuid: nil,
			nodes: [
				DocumentNode(
					value: parent,
					children: [DocumentNode(value: target, children: [])]
				)
			]
		)

		// Act
		#expect(throws: NavigationResolver.NavigationError.rootNotFound) {
			try sut.resolve(content: content)
		}

		// Assert
		#expect(sut.path.root == initialRoot)
		#expect(sut.path.suffix == [parent.id, target.id])
	}

	@Test func focus_drawsPathFromInitialRootToTarget() throws {
		// Arrange
		let documentRoot = Item(text: "Document root")
		let initialRoot = Item(text: "Initial root")
		let parent = Item(text: "Parent")
		let target = Item(text: "Target")
		let sut = NavigationResolver(path: NavigationPath(root: initialRoot.id))
		let content = DocumentContent(
			uuid: nil,
			nodes: [
				DocumentNode(
					value: documentRoot,
					children: [
						DocumentNode(
							value: initialRoot,
							children: [
								DocumentNode(
									value: parent,
									children: [DocumentNode(value: target, children: [])]
								)
							]
						)
					]
				)
			]
		)

		// Act
		try sut.focus(on: target.id, in: content)

		// Assert
		#expect(sut.path.root == initialRoot.id)
		#expect(sut.path.suffix == [parent.id, target.id])
	}

	@Test func focus_drawsPathFromDocumentRootToTarget() throws {
		// Arrange
		let parent = Item(text: "Parent")
		let target = Item(text: "Target")
		let sut = NavigationResolver()
		let content = DocumentContent(
			uuid: nil,
			nodes: [
				DocumentNode(
					value: parent,
					children: [DocumentNode(value: target, children: [])]
				)
			]
		)

		// Act
		try sut.focus(on: target.id, in: content)

		// Assert
		#expect(sut.path.root == nil)
		#expect(sut.path.suffix == [parent.id, target.id])
	}
}

//
//  UnitPresenterTests.swift
//  macOSTests
//
//  Created by Anton Cherkasov on 25.01.2025.
//

import Testing
import Foundation
import Hierarchy
import CoreModule
import CoreSettings
@testable import Nested_List

final class UnitPresenterTests {

	var sut: ContentPresenter!

	// MARK: - DI

	var view: UnitViewMock!
	var interactor: UnitInteractorMock!
	var settingsProvider: StateProviderMock<Settings>!

	init() {
		view = UnitViewMock()
		interactor = UnitInteractorMock()
		settingsProvider = StateProviderMock<Settings>()
		sut = ContentPresenter(settingsProvider: settingsProvider)
		sut.view = view
		sut.interactor = interactor
	}

	deinit {
		sut = nil
		view = nil
		interactor = nil
		settingsProvider = nil
	}
}

// MARK: - ContentPresenterProtocol test-cases
extension UnitPresenterTests {

	@Test func testPresent() {
		// Arrange
		let content = makeContent()
		settingsProvider.stubs.state = .standart

		// Act
		sut.present(content)

		// Assert
		guard case let .display(snapshot) = view.invocations.first else {
			Issue.record("Expect display invocation")
			return
		}

		#expect(snapshot.identifiers.count == 2)
	}
}

// MARK: - ListDelegate test-cases
extension UnitPresenterTests {

	@Test func test_handleDoubleClick() {
		// Arrange
		let expectedId: UUID = .random
		settingsProvider.stubs.state = .standart

		// Act
		sut.handleDoubleClick(on: expectedId)

		guard case let .toggleStatus(id, moveToEnd) = interactor.invocations.first else {
			Issue.record("Expect toggleStatus invocation")
			return
		}

		#expect(id == expectedId)
		#expect(moveToEnd == false)
	}

	@Test func test_handleDoubleClick_whenCompletionBehaviourIsMoveToEnd() {
		// Arrange
		let expectedId: UUID = .random
		settingsProvider.stubs.state = Settings(completionBehaviour: .moveToEnd)

		// Act
		sut.handleDoubleClick(on: expectedId)

		guard case let .toggleStatus(id, moveToEnd) = interactor.invocations.first else {
			Issue.record("Expect toggleStatus invocation")
			return
		}

		#expect(id == expectedId)
		#expect(moveToEnd == true)
	}
}

// MARK: - UnitViewOutput
extension UnitPresenterTests {

	@Test func test_viewDidLoad() {
		// Act
		sut.viewDidChange(state: .didLoad)

		// Assert

		guard case .fetchData = interactor.invocations.first else {
			Issue.record("Expect fetchData invocation")
			return
		}

		guard case let .expand(ids) = view.invocations.first else {
			Issue.record("Expect display invocation")
			return
		}

		#expect(ids == nil)
	}

	@Test func test_userCreateNewItem() {
		// Arrange
		view.stubs.selection = [.random, .random]
		interactor.stubs.newItem = .random

		// Act
		sut.userDidClickedItem(with: .newItem)

		// Assert
		guard case let .scroll(id) = view.invocations[0] else {
			Issue.record("Expect scroll invocation")
			return
		}
		#expect(id == interactor.stubs.newItem)

		guard case let .expand(id) = view.invocations[1] else {
			Issue.record("Expect expand invocation")
			return
		}
		#expect(id?.first == view.selection.first)

		guard case let .focus(id, key) = view.invocations[2] else {
			Issue.record("Expect focus invocation")
			return
		}

		#expect(key == "title")
		#expect(id == interactor.stubs.newItem)
	}

	@Test func test_userDeleteItem() {
		// Arrange
		view.stubs.selection = [.random, .random]

		// Act
		sut.userDidClickedItem(with: .delete)

		// Assert
		guard case let .deleteItems(ids) = interactor.invocations[0] else {
			Issue.record("Expect deleteItems invocation")
			return
		}
		#expect(ids == view.stubs.selection)
	}

	@Test func test_userChangedStatus() {
		// Arrange
		let firstId = UUID()
		let secondId = UUID()

		view.stubs.selection = [firstId, secondId]
		settingsProvider.stubs.state = .standart

		let firstNode: Node<Item> = .init(value: .init(uuid: firstId, isDone: false, text: .random))
		let secondNode: Node<Item> = .init(value: .init(uuid: secondId, isDone: false, text: .random))

		sut.present(.init(nodes: [firstNode, secondNode]))

		interactor.clear()
		view?.clear()

		// Act
		sut.userDidClickedItem(with: .completed)

		// Assert
		guard case let .setStatus(status, ids, moveToEnd) = interactor.invocations[0] else {
			Issue.record("Expect setStatus invocation")
			return
		}

		#expect(status == true)
		#expect(ids == view.stubs.selection)
		#expect(moveToEnd == false)
	}

	@Test func test_userChangedStatus_whenCompletionBehaviourIsMoveToEnd() {
		// Arrange
		let firstId = UUID()
		let secondId = UUID()

		view.stubs.selection = [firstId, secondId]
		settingsProvider.stubs.state = Settings(completionBehaviour: .moveToEnd)

		let firstNode: Node<Item> = .init(value: .init(uuid: firstId, isDone: false, text: .random))
		let secondNode: Node<Item> = .init(value: .init(uuid: secondId, isDone: false, text: .random))

		sut.present(.init(nodes: [firstNode, secondNode]))

		interactor.clear()
		view?.clear()

		// Act
		sut.userDidClickedItem(with: .completed)

		// Assert
		guard case let .setStatus(status, ids, moveToEnd) = interactor.invocations[0] else {
			Issue.record("Expect setStatus invocation")
			return
		}

		#expect(status == true)
		#expect(ids == view.stubs.selection)
		#expect(moveToEnd == true)
	}

	@Test func test_userChangedMark() {
		// Arrange

		let firstId = UUID()
		let secondId = UUID()

		view.stubs.selection = [.random, .random]
		settingsProvider.stubs.state = .standart

		let firstNode: Node<Item> = .init(value: .init(uuid: firstId, isMarked: false, text: .random))
		let secondNode: Node<Item> = .init(value: .init(uuid: secondId, isMarked: false, text: .random))

		sut.present(.init(nodes: [firstNode, secondNode]))

		interactor.clear()

		// Act
		sut.userDidClickedItem(with: .marked)

		// Assert
		guard case let .setMark(isMarked, ids, moveToTop) = interactor.invocations[0] else {
			Issue.record("Expect setMark invocation")
			return
		}

		#expect(isMarked == true)
		#expect(ids == view.stubs.selection)
		#expect(moveToTop == false)
	}

	@Test func test_userChangedStyle() {
		// Arrange
		let firstId = UUID()
		let secondId = UUID()

		view.stubs.selection = [firstId, secondId]
		settingsProvider.stubs.state = .standart

		let firstNode: Node<Item> = .init(value: .init(uuid: firstId, text: .random, style: .item))
		let secondNode: Node<Item> = .init(value: .init(uuid: secondId, text: .random, style: .item))

		sut.present(.init(nodes: [firstNode, secondNode]))

		interactor.clear()
		// Act
		sut.userDidClickedItem(with: .section)

		// Assert
		guard case let .setStyle(style, ids) = interactor.invocations[0] else {
			Issue.record("Expect setStyle invocation")
			return
		}

		#expect(style == .section)
		#expect(ids == view.stubs.selection)
	}

	@Test func test_userAddNote() {
		// Arrange
		let firstId = UUID()
		let secondId = UUID()

		view.stubs.selection = [firstId, secondId]
		settingsProvider.stubs.state = .standart

		let firstNode: Node<Item> = .init(value: .init(uuid: firstId, text: .random))
		let secondNode: Node<Item> = .init(value: .init(uuid: secondId, text: .random))

		sut.present(.init(nodes: [firstNode, secondNode]))

		interactor.clear()
		view?.clear()

		// Act
		sut.userDidClickedItem(with: .note)

		// Assert
		guard case let .setNote(note, ids) = interactor.invocations[0] else {
			Issue.record("Expect addNote invocation")
			return
		}

		#expect(note != nil)
		#expect(interactor.invocations.count == 1)
		#expect(ids == [firstId, secondId])

		#expect(view.invocations.count == 1)
		guard case let .focus(id, key) = view.invocations[0] else {
			Issue.record("Expect focus invocation")
			return
		}

		#expect(id == firstId)
		#expect(key == "subtitle")
	}

	@Test func test_userDeleteNote() {
		// Arrange
		let firstId = UUID()
		let secondId = UUID()

		view.stubs.selection = [firstId, secondId]
		settingsProvider.stubs.state = .standart

		let firstNode: Node<Item> = .init(value: .init(uuid: firstId, text: .random, note: .random))
		let secondNode: Node<Item> = .init(value: .init(uuid: secondId, text: .random))

		sut.present(.init(nodes: [firstNode, secondNode]))

		interactor.clear()
		view?.clear()

		// Act
		sut.userDidClickedItem(with: .note)

		// Assert
		guard case let .setNote(note, ids) = interactor.invocations[0] else {
			Issue.record("Expect deleteNote invocation")
			return
		}

		#expect(note == nil)
		#expect(ids == view.stubs.selection)
	}
}

// MARK: - Helpers
private extension UnitPresenterTests {

	func makeContent() -> Content {
		.init(nodes: [.init(value: .random), .init(value: .random)])
	}
}

//
//  UnitPresenterTests.swift
//  macOSTests
//
//  Created by Anton Cherkasov on 25.01.2025.
//

import Testing
import Foundation
import AppKit
import Hierarchy
import CoreModule
import CoreSettings
import DesignSystem
@testable import Nested_List

@MainActor
final class UnitPresenterTests {

	var sut: ContentPresenter!

	// MARK: - DI

	var view: UnitViewMock!
	var interactor: UnitInteractorMock!
	var router: UnitRouterMock!
	var settingsProvider: StateProviderMock<Settings>!

	init() {
		view = UnitViewMock()
		interactor = UnitInteractorMock()
		router = UnitRouterMock()
		settingsProvider = StateProviderMock<Settings>()
		sut = ContentPresenter(router: router, settingsProvider: settingsProvider)
		sut.view = view
		sut.interactor = interactor
	}

	deinit {
		sut = nil
		view = nil
		interactor = nil
		router = nil
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
		guard case let .display(state) = view.invocations.first else {
			Issue.record("Expect display invocation")
			return
		}

		guard case let .list(snapshot) = state else {
			Issue.record("Expect list state")
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
		sut.menuItemClicked(.newItem)

		// Assert
		guard case let .newItem(text, isStrikethrough, note, iconName, tintColor, target) = interactor.invocations[0] else {
			Issue.record("Expect newItem invocation")
			return
		}
		#expect(!text.isEmpty)
		#expect(isStrikethrough == false)
		#expect(note == nil)
		#expect(iconName == nil)
		#expect(tintColor == nil)
		#expect(target == view.selection.first)

		guard case let .expand(id) = view.invocations[0] else {
			Issue.record("Expect expand invocation")
			return
		}
		#expect(id?.first == view.selection.first)

		guard case let .scroll(id) = view.invocations[1] else {
			Issue.record("Expect scroll invocation")
			return
		}
		#expect(id == interactor.stubs.newItem)

		guard case let .focus(id, key) = view.invocations[2] else {
			Issue.record("Expect focus invocation")
			return
		}
		#expect(id == interactor.stubs.newItem)
		#expect(key == "title")
	}

	@Test func test_userDeleteItem() {
		// Arrange
		view.stubs.selection = [.random, .random]

		// Act
		sut.menuItemClicked(.delete)

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

		let firstNode: Node<Item> = .init(value: .init(uuid: firstId, text: .random))
		let secondNode: Node<Item> = .init(value: .init(uuid: secondId, text: .random))

		sut.present(.init(nodes: [firstNode, secondNode]))

		interactor.clear()
		view?.clear()

		// Act
		sut.menuItemClicked(.completed)

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

		let firstNode: Node<Item> = .init(value: .init(uuid: firstId, text: .random))
		let secondNode: Node<Item> = .init(value: .init(uuid: secondId, text: .random))

		sut.present(.init(nodes: [firstNode, secondNode]))

		interactor.clear()
		view?.clear()

		// Act
		sut.menuItemClicked(.completed)

		// Assert
		guard case let .setStatus(status, ids, moveToEnd) = interactor.invocations[0] else {
			Issue.record("Expect setStatus invocation")
			return
		}

		#expect(status == true)
		#expect(ids == view.stubs.selection)
		#expect(moveToEnd == true)
	}

	@Test func test_userChangedColor() {
		// Arrange

		view.stubs.selection = [.random, .random]

		// Act
		sut.menuItemClicked(.color)

		// Assert
		guard case .showColorPicker = router.invocations[0] else {
			Issue.record("Expect showColorPicker invocation")
			return
		}

		router.stubs.showColorPickerCompletionHandler?(.yellow)

		guard case let .setColor(color, ids) = interactor.invocations[0] else {
			Issue.record("Expect setColor invocation")
			return
		}

		#expect(color == .yellow)
		#expect(ids == view.stubs.selection)
	}

	@Test func test_userChangedIcon() {
		// Arrange
		view.stubs.selection = [.random, .random]
		// Act
		sut.menuItemClicked(.icon)

		// Assert
		guard case .showIconPicker = router.invocations[0] else {
			Issue.record("Expect showIconPicker invocation")
			return
		}

		router.stubs.showIconPickerCompletionHandler?(.package)

		guard case let .setIcon(icon, ids) = interactor.invocations[0] else {
			Issue.record("Expect setIcon invocation")
			return
		}

		#expect(icon == .package)
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
		sut.menuItemClicked(.note)

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
		let secondNode: Node<Item> = .init(value: .init(uuid: secondId, text: .random, note: .random))

		sut.present(.init(nodes: [firstNode, secondNode]))

		interactor.clear()
		view?.clear()

		// Act
		sut.menuItemClicked(.note)

		// Assert
		guard case let .setNote(note, ids) = interactor.invocations[0] else {
			Issue.record("Expect deleteNote invocation")
			return
		}

		#expect(note == nil)
		#expect(ids == view.stubs.selection)
	}
}

// MARK: - DropDelegate test-cases
extension UnitPresenterTests {

	@Test func test_moveItems() {
		// Arrange
		let expectedIds: [UUID] = [.random, .random]
		let expectedDestination: Destination<UUID> = .toRoot

		// Act
		sut.move(expectedIds, to: expectedDestination)

		// Assert
		guard case let .move(ids, destination) = interactor.invocations.first else {
			Issue.record("Expect move invocation")
			return
		}
		#expect(ids == expectedIds)
		#expect(destination == expectedDestination)
	}

	@Test func test_copyItems() {
		// Arrange
		let expectedIds: [UUID] = [.random]
		let expectedDestination: Destination<UUID> = .onItem(with: .random)

		// Act
		sut.copy(expectedIds, to: expectedDestination)

		// Assert
		guard case let .copy(ids, destination) = interactor.invocations.first else {
			Issue.record("Expect copy invocation")
			return
		}
		#expect(ids == expectedIds)
		#expect(destination == expectedDestination)
	}

	@Test func test_validateMovement() {
		// Arrange
		let expectedIds: [UUID] = [.random]
		let expectedDestination: Destination<UUID> = .onItem(with: .random)

		interactor.stubs.validateMovement = true

		// Act
		let result = sut.validateMovement(expectedIds, to: expectedDestination)

		// Assert
		#expect(result)
		guard case let .validateMovement(ids, destination) = interactor.invocations.first else {
			Issue.record("Expect validateMovement invocation")
			return
		}
		#expect(ids == expectedIds)
		#expect(destination == expectedDestination)
	}

	@Test func test_validateDrop() {
		// Arrange
		let destination: Destination<UUID> = .toRoot
		let stringType = NSPasteboard.PasteboardType.string.rawValue
		let itemType = "dev.zeroindex.ListAdapter.item"
		let stringInfo = PasteboardInfo(items: [.init(data: [stringType: Data("value".utf8)])])
		let itemInfo = PasteboardInfo(items: [.init(data: [itemType: Data([0x01])])])
		let unknownInfo = PasteboardInfo(items: [.init(data: ["unknown/type": Data([0x02])])])

		// Act
		let validStringResult = sut.validateDrop(stringInfo, to: destination)
		let validItemResult = sut.validateDrop(itemInfo, to: destination)
		let invalidResult = sut.validateDrop(unknownInfo, to: destination)

		// Assert
		#expect(validStringResult)
		#expect(validItemResult)
		#expect(!invalidResult)
	}

	@Test func test_dropItemsFromPasteboard() {
		// Arrange
		let destination: Destination<UUID> = .toRoot
		let itemType = "dev.zeroindex.ListAdapter.item"
		let first = Data([0x01])
		let second = Data([0x02])
		let info = PasteboardInfo(
			items: [
				.init(data: [itemType: first]),
				.init(data: [itemType: second])
			]
		)

		// Act
		sut.drop(info, to: destination)

		// Assert
		guard case let .insertItems(data, destination: actualDestination) = interactor.invocations.first else {
			Issue.record("Expect insertItems invocation")
			return
		}
		#expect(data == [first, second])
		#expect(actualDestination == destination)
	}

	@Test func test_dropStringsFromPasteboard() {
		// Arrange
		let destination: Destination<UUID> = .toRoot
		let stringType = NSPasteboard.PasteboardType.string.rawValue
		let first = Data("one".utf8)
		let second = Data("two".utf8)
		let info = PasteboardInfo(
			items: [
				.init(data: [stringType: first]),
				.init(data: [stringType: second])
			]
		)

		// Act
		sut.drop(info, to: destination)

		// Assert
		guard case let .insertStringsFromData(data, destination: actualDestination) = interactor.invocations.first else {
			Issue.record("Expect insertStringsFromData invocation")
			return
		}
		#expect(data == [first, second])
		#expect(actualDestination == destination)
	}

	@Test func test_availableTypes() {
		// Act
		let result = sut.availableTypes()

		// Assert
		#expect(result.contains(NSPasteboard.PasteboardType.string.rawValue))
		#expect(result.contains("dev.zeroindex.ListAdapter.item"))
		#expect(result.count == 2)
	}
}

// MARK: - DragDelegate test-cases
extension UnitPresenterTests {

	@Test func test_writeToPasteboard() {
		// Arrange
		let id = UUID()
		let node: Node<Item> = .init(value: .init(uuid: id, text: "Title"))
		interactor.stubs.nodes = [node]
		let pasteboard = PasteboardMock()

		// Act
		sut.write(ids: [id], to: pasteboard)

		// Assert
		guard case let .nodes(ids) = interactor.invocations.first else {
			Issue.record("Expect nodes invocation")
			return
		}
		#expect(ids == [id])
		#expect(pasteboard.invocations.count == 1)
		guard case let .setInfo(info, clearContents) = pasteboard.invocations.first else {
			Issue.record("Expect setInfo invocation")
			return
		}
		#expect(clearContents == false)
		#expect(info.containsInfo(of: NSPasteboard.PasteboardType.string.rawValue))
		#expect(info.containsInfo(of: "dev.zeroindex.ListAdapter.item"))
	}
}

// MARK: - Helpers
private extension UnitPresenterTests {

	func makeContent() -> Content {
		.init(nodes: [.init(value: .random), .init(value: .random)])
	}
}

private final class PasteboardMock {

	private(set) var invocations: [Action] = []
}

// MARK: - PasteboardProtocol
extension PasteboardMock: PasteboardProtocol {

	func contains(_ types: Set<String>) -> Bool {
		invocations.append(.contains(types))
		return false
	}

	func setInfo(_ info: PasteboardInfo, clearContents: Bool) {
		invocations.append(.setInfo(info, clearContents: clearContents))
	}

	func getInfo() -> PasteboardInfo? {
		invocations.append(.getInfo)
		return nil
	}
}

private extension PasteboardMock {

	enum Action {
		case contains(Set<String>)
		case setInfo(PasteboardInfo, clearContents: Bool)
		case getInfo
	}
}

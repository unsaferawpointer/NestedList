//
//  UnitPresenterTests.swift
//  macOSTests
//
//  Created by Anton Cherkasov on 25.01.2025.
//

import Testing
import CoreModule
@testable import Nested_List

final class UnitPresenterTests {

	var sut: UnitPresenter!

	// MARK: - DI

	var view: UnitViewMock!
	var interactor: UnitInteractorMock!

	init() {
		view = UnitViewMock()
		interactor = UnitInteractorMock()
		sut = UnitPresenter()
		sut.view = view
		sut.interactor = interactor
	}

	deinit {
		sut = nil
		view = nil
		interactor = nil
	}
}

// MARK: - UnitPresenterProtocol test-cases
extension UnitPresenterTests {

	@Test func testPresent() {
		// Arrange
		let content = makeContent()

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

// MARK: - UnitViewOutput
extension UnitPresenterTests {

	@Test func test_viewDidLoad() {
		// Act
		sut.viewDidLoad()

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
		sut.userCreateNewItem()

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

		guard case let .focus(id) = view.invocations[2] else {
			Issue.record("Expect focus invocation")
			return
		}
		#expect(id == interactor.stubs.newItem)
	}

	@Test func test_userDeleteItem() {
		// Arrange
		view.stubs.selection = [.random, .random]

		// Act
		sut.userDeleteItem()

		// Assert
		guard case let .deleteItems(ids) = interactor.invocations[0] else {
			Issue.record("Expect deleteItems invocation")
			return
		}
		#expect(ids == view.stubs.selection)
	}

	@Test func test_userChangedStatus() {
		// Arrange
		view.stubs.selection = [.random, .random]

		// Act
		sut.userChangedStatus(true)

		// Assert
		guard case let .setStatus(status, ids, moveToEnd) = interactor.invocations[0] else {
			Issue.record("Expect setStatus invocation")
			return
		}

		#expect(status == true)
		#expect(ids == view.stubs.selection)
		#expect(moveToEnd == false)
	}

	@Test func test_userChangedMark() {
		// Arrange
		view.stubs.selection = [.random, .random]

		// Act
		sut.userChangedMark(true)

		// Assert
		guard case let .setMark(isMarked, ids) = interactor.invocations[0] else {
			Issue.record("Expect setMark invocation")
			return
		}

		#expect(isMarked == true)
		#expect(ids == view.stubs.selection)
	}

	@Test func test_userChangedStyle() {
		// Arrange
		view.stubs.selection = [.random, .random]

		// Act
		sut.userChangedStyle(.section)

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
		view.stubs.selection = [.random, .random]

		// Act
		sut.userAddNote()

		// Assert
		guard case let .addNote(ids) = interactor.invocations[0] else {
			Issue.record("Expect addNote invocation")
			return
		}

		#expect(ids == view.stubs.selection)
	}

	@Test func test_userDeleteNote() {
		// Arrange
		view.stubs.selection = [.random, .random]

		// Act
		sut.userDeleteNote()

		// Assert
		guard case let .deleteNote(ids) = interactor.invocations[0] else {
			Issue.record("Expect deleteNote invocation")
			return
		}

		#expect(ids == view.stubs.selection)
	}
}

// MARK: - Helpers
private extension UnitPresenterTests {

	func makeContent() -> Content {
		.init(nodes: [.init(value: .random), .init(value: .random)])
	}
}

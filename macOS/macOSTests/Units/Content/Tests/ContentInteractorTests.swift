//
//  ContentInteractorTests.swift
//  macOSTests
//
//  Created by OpenAI on 25.06.2026.
//

import Testing
import Foundation
import CoreModule
import Hierarchy
@testable import Nested_List

@MainActor
struct ContentInteractorTests {

	@Test func newItem_proxiesToCommonInteractorWithRelativeRootTarget() {
		// Arrange
		let root = UUID()
		let base = CommonInteractorMock()
		let sut = makeSUT(root: root, base: base)

		// Act
		let result = sut.newItem(
			"Title",
			isStrikethrough: true,
			note: "Note",
			iconName: .bolt,
			tintColor: .cyan,
			target: nil
		)

		// Assert
		#expect(result == base.stubs.newItem)
		guard case let .newItem(text, isStrikethrough, note, iconName, tintColor, target) = base.invocations.first else {
			Issue.record("Expect newItem invocation")
			return
		}
		#expect(text == "Title")
		#expect(isStrikethrough == true)
		#expect(note == "Note")
		#expect(iconName == .bolt)
		#expect(tintColor == .cyan)
		#expect(target == root)
	}

	@Test func destinationBasedMethods_proxyRelativeToRoot() {
		// Arrange
		let root = UUID()
		let ids = [UUID(), UUID()]
		let data = Data("payload".utf8)
		let destination: Destination<UUID> = .inRoot(atIndex: 1)
		let expectedDestination: Destination<UUID> = .inItem(with: root, atIndex: 1)
		let base = CommonInteractorMock()
		base.stubs.validateMovement = true
		let sut = makeSUT(root: root, base: base)

		// Act
		let isValid = sut.validateMovement(ids, to: destination)
		sut.move(ids, to: destination)
		sut.copy(ids, to: destination)
		sut.insertStrings(["A"], to: destination)
		sut.insertStrings([data], to: destination)
		sut.insertItems([data], to: destination)

		// Assert
		#expect(isValid)
		#expect(base.invocations.count == 6)
		guard case let .validateMovement(actualIds, actualDestination) = base.invocations[0] else {
			Issue.record("Expect validateMovement invocation")
			return
		}
		#expect(actualIds == ids)
		#expect(actualDestination == expectedDestination)

		guard case let .move(actualIds, actualDestination) = base.invocations[1] else {
			Issue.record("Expect move invocation")
			return
		}
		#expect(actualIds == ids)
		#expect(actualDestination == expectedDestination)

		guard case let .copy(actualIds, actualDestination) = base.invocations[2] else {
			Issue.record("Expect copy invocation")
			return
		}
		#expect(actualIds == ids)
		#expect(actualDestination == expectedDestination)

		guard case let .insertStrings(strings, actualDestination) = base.invocations[3] else {
			Issue.record("Expect insertStrings invocation")
			return
		}
		#expect(strings == ["A"])
		#expect(actualDestination == expectedDestination)

		guard case let .insertStrings(strings, actualDestination) = base.invocations[4] else {
			Issue.record("Expect insertStrings from data invocation")
			return
		}
		#expect(strings == ["payload"])
		#expect(actualDestination == expectedDestination)

		guard case let .insertItems(actualData, actualDestination) = base.invocations[5] else {
			Issue.record("Expect insertItems invocation")
			return
		}
		#expect(actualData == [data])
		#expect(actualDestination == expectedDestination)
	}
}

// MARK: - Helpers
private extension ContentInteractorTests {

	func makeSUT(root: UUID? = nil, base: CommonInteractorMock) -> ContentInteractor {
		let storage = DocumentStorage(
			stateProvider: StateProvider(initialState: Content.empty),
			contentProvider: JsonDataProvider(),
			undoManager: nil
		)
		let sut = ContentInteractor(storage: storage, root: root)
		sut.base = base
		return sut
	}
}

private final class CommonInteractorMock {

	private(set) var invocations: [Action] = []
	var stubs = Stubs()
}

// MARK: - CommonInteractorProtocol
extension CommonInteractorMock: CommonInteractorProtocol {

	func newItem(
		_ text: String,
		isStrikethrough: Bool?,
		note: String?,
		iconName: IconName?,
		tintColor: ItemColor?,
		target: UUID?
	) -> UUID {
		invocations.append(
			.newItem(
				text,
				isStrikethrough: isStrikethrough,
				note: note,
				iconName: iconName,
				tintColor: tintColor,
				target: target
			)
		)
		return stubs.newItem
	}

	func deleteItems(_ ids: [UUID]) {
		invocations.append(.deleteItems(ids))
	}

	func validateMovement(_ ids: [UUID], to destination: Destination<UUID>) -> Bool {
		invocations.append(.validateMovement(ids, destination))
		return stubs.validateMovement
	}

	func move(_ ids: [UUID], to destination: Destination<UUID>) {
		invocations.append(.move(ids, destination))
	}

	func insertStrings(_ strings: [String], to destination: Destination<UUID>) {
		invocations.append(.insertStrings(strings, destination))
	}

	func setSubitemsHidden(_ hidden: Bool, for ids: [UUID]) {
		invocations.append(.setSubitemsHidden(hidden, ids))
	}

	func setIcon(_ name: IconName?, for ids: [UUID]) {
		invocations.append(.setIcon(name, ids))
	}

	func setColor(_ color: ItemColor?, for ids: [UUID]) {
		invocations.append(.setColor(color, ids))
	}

	func setStatus(_ isStrikethrough: Bool, for ids: [UUID], moveToEnd: Bool) {
		invocations.append(.setStatus(isStrikethrough, ids, moveToEnd))
	}

	func set(note: String?, for ids: [UUID]) {
		invocations.append(.setNote(note, ids))
	}

	func set(text: String, note: String?, for id: UUID) {
		invocations.append(.setText(text, note, id))
	}

	func copy(_ ids: [UUID], to destination: Destination<UUID>) {
		invocations.append(.copy(ids, destination))
	}

	func toggleStrikethrough(for id: UUID, moveToEnd: Bool) {
		invocations.append(.toggleStrikethrough(id, moveToEnd))
	}

	func insertItems(_ data: [Data], to destination: Destination<UUID>) {
		invocations.append(.insertItems(data, destination))
	}

	func insertNodes(_ nodes: [any TreeNode<Item>], to destination: Destination<UUID>) {
		invocations.append(.insertNodes(nodes, destination))
	}

	func nodes(for ids: [UUID]) -> [any TreeNode<Item>] {
		invocations.append(.nodes(ids))
		return stubs.nodes
	}

	func data(of id: UUID) -> Data? {
		invocations.append(.data(id))
		return stubs.data[id]
	}

	func string(for ids: [UUID]) -> String {
		invocations.append(.string(ids))
		return stubs.string
	}
}

// MARK: - Nested data structs
extension CommonInteractorMock {

	enum Action {
		case newItem(_ text: String, isStrikethrough: Bool?, note: String?, iconName: IconName?, tintColor: ItemColor?, target: UUID?)
		case deleteItems(_ ids: [UUID])
		case validateMovement(_ ids: [UUID], _ destination: Destination<UUID>)
		case move(_ ids: [UUID], _ destination: Destination<UUID>)
		case insertStrings(_ strings: [String], _ destination: Destination<UUID>)
		case setSubitemsHidden(_ hidden: Bool, _ ids: [UUID])
		case setIcon(_ name: IconName?, _ ids: [UUID])
		case setColor(_ color: ItemColor?, _ ids: [UUID])
		case setStatus(_ isStrikethrough: Bool, _ ids: [UUID], _ moveToEnd: Bool)
		case setNote(_ note: String?, _ ids: [UUID])
		case setText(_ text: String, _ note: String?, _ id: UUID)
		case copy(_ ids: [UUID], _ destination: Destination<UUID>)
		case toggleStrikethrough(_ id: UUID, _ moveToEnd: Bool)
		case insertItems(_ data: [Data], _ destination: Destination<UUID>)
		case insertNodes(_ nodes: [any TreeNode<Item>], _ destination: Destination<UUID>)
		case nodes(_ ids: [UUID])
		case data(_ id: UUID)
		case string(_ ids: [UUID])
	}

	struct Stubs {
		var newItem = UUID()
		var validateMovement = false
		var nodes: [any TreeNode<Item>] = []
		var data: [UUID: Data] = [:]
		var string = ""
	}
}

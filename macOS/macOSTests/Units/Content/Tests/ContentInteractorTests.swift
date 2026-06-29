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
		let properties = ItemProperties(
			text: "Title",
			note: "Note",
			options: [.strikethrough],
			iconName: .bolt,
			tintColor: .cyan
		)
		let result = sut.newItem(with: properties, target: nil)

		// Assert
		#expect(result == base.stubs.newItem)
		guard case let .newItem(actualProperties, target) = base.invocations.first else {
			Issue.record("Expect newItem invocation")
			return
		}
		#expect(actualProperties.text == "Title")
		#expect(actualProperties.options == [.strikethrough])
		#expect(actualProperties.note == "Note")
		#expect(actualProperties.iconName == .bolt)
		#expect(actualProperties.tintColor == .cyan)
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

	@Test func propertyMethods_proxyToCommonInteractorWithoutDownstreamPropagation() {
		// Arrange
		let ids = [UUID(), UUID()]
		let base = CommonInteractorMock()
		let sut = makeSUT(base: base)

		// Act
		sut.setSubitemsHidden(true, for: ids)
		sut.setIcon(.bolt, for: ids)
		sut.setColor(.cyan, for: ids)
		sut.set(note: "Note", for: ids)

		// Assert
		#expect(base.invocations.count == 4)
		guard case let .setProperty(property, actualIds, downstream) = base.invocations[0] else {
			Issue.record("Expect setProperty invocation")
			return
		}
		#expect(property == .isSubitemsHidden(true))
		#expect(actualIds == ids)
		#expect(downstream == false)

		guard case let .setProperty(property, actualIds, downstream) = base.invocations[1] else {
			Issue.record("Expect setProperty invocation")
			return
		}
		#expect(property == .iconName(.bolt))
		#expect(actualIds == ids)
		#expect(downstream == false)

		guard case let .setProperty(property, actualIds, downstream) = base.invocations[2] else {
			Issue.record("Expect setProperty invocation")
			return
		}
		#expect(property == .tintColor(.cyan))
		#expect(actualIds == ids)
		#expect(downstream == false)

		guard case let .setProperty(property, actualIds, downstream) = base.invocations[3] else {
			Issue.record("Expect setProperty invocation")
			return
		}
		#expect(property == .note("Note"))
		#expect(actualIds == ids)
		#expect(downstream == false)
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

	func newItem(with properties: ItemProperties, target: UUID?) -> UUID {
		invocations.append(.newItem(properties, target: target))
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

	func setStatus(_ isStrikethrough: Bool, for ids: [UUID], moveToEnd: Bool) {
		invocations.append(.setStatus(isStrikethrough, ids, moveToEnd))
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

	func setProperty<T>(
		_ property: WritableKeyPath<Item, T>,
		to value: T,
		for ids: [UUID],
		downstream: Bool
	) {
		guard let property = Property(property: property, value: value) else {
			Issue.record("Unsupported setProperty key path")
			return
		}
		invocations.append(.setProperty(property, ids, downstream: downstream))
	}
}

// MARK: - Nested data structs
extension CommonInteractorMock {

	enum Action {
		case newItem(_ properties: ItemProperties, target: UUID?)
		case deleteItems(_ ids: [UUID])
		case validateMovement(_ ids: [UUID], _ destination: Destination<UUID>)
		case move(_ ids: [UUID], _ destination: Destination<UUID>)
		case insertStrings(_ strings: [String], _ destination: Destination<UUID>)
		case setStatus(_ isStrikethrough: Bool, _ ids: [UUID], _ moveToEnd: Bool)
		case setText(_ text: String, _ note: String?, _ id: UUID)
		case copy(_ ids: [UUID], _ destination: Destination<UUID>)
		case toggleStrikethrough(_ id: UUID, _ moveToEnd: Bool)
		case insertItems(_ data: [Data], _ destination: Destination<UUID>)
		case insertNodes(_ nodes: [any TreeNode<Item>], _ destination: Destination<UUID>)
		case nodes(_ ids: [UUID])
		case data(_ id: UUID)
		case string(_ ids: [UUID])
		case setProperty(_ property: Property, _ ids: [UUID], downstream: Bool)
	}

	enum Property: Equatable {
		case isSubitemsHidden(Bool)
		case iconName(IconName?)
		case tintColor(ItemColor?)
		case note(String?)

		init?<T>(property: WritableKeyPath<Item, T>, value: T) {
			switch property {
			case \Item.isSubitemsHidden:
				guard let value = value as? Bool else {
					return nil
				}
				self = .isSubitemsHidden(value)
			case \Item.iconName:
				guard let value = value as? IconName? else {
					return nil
				}
				self = .iconName(value)
			case \Item.tintColor:
				guard let value = value as? ItemColor? else {
					return nil
				}
				self = .tintColor(value)
			case \Item.note:
				guard let value = value as? String? else {
					return nil
				}
				self = .note(value)
			default:
				return nil
			}
		}
	}

	struct Stubs {
		var newItem = UUID()
		var validateMovement = false
		var nodes: [any TreeNode<Item>] = []
		var data: [UUID: Data] = [:]
		var string = ""
	}
}

//
//  ContentUnitInteractorMock.swift
//  iOSTests
//
//  Created by Anton Cherkasov on 06.07.2026.
//

import Foundation
import CoreModule
import Hierarchy
@testable import iOS

@MainActor
final class ContentUnitInteractorMock {

	private(set) var invocations: [Action] = []
	var stubs = Stubs()
}

// MARK: - ContentUnitInteractorProtocol
extension ContentUnitInteractorMock: ContentUnitInteractorProtocol {

	func fetchData() -> (Item?, Snapshot<Item>) {
		invocations.append(.fetchData)
		return (stubs.fetchedItem, stubs.snapshot)
	}

	func newItem(with properties: ItemProperties, target: UUID?) -> UUID {
		invocations.append(.newItem(properties, target: target))
		return stubs.newItem
	}

	func deleteItems(_ ids: [UUID]) {
		invocations.append(.deleteItems(ids))
	}

	func setStatus(_ isStrikethrough: Bool, for ids: [UUID], moveToEnd: Bool) {
		invocations.append(.setStatus(isStrikethrough, ids: ids, moveToEnd: moveToEnd))
	}

	func setSubitemsHidden(_ hidden: Bool, for ids: [UUID]) {
		invocations.append(.setSubitemsHidden(hidden, ids: ids))
	}

	func setColor(_ color: ItemColor?, for ids: [UUID]) {
		invocations.append(.setColor(color, ids: ids))
	}

	func setIcon(_ name: IconName?, for ids: [UUID]) {
		invocations.append(.setIcon(name, ids: ids))
	}

	func set(_ text: String, note: String?, for id: UUID) {
		invocations.append(.setText(text: text, note: note, id: id))
	}

	func item(for id: UUID) -> Item {
		invocations.append(.item(id))
		return stubs.item
	}

	func data(of id: UUID) -> Data? {
		invocations.append(.data(id))
		return stubs.data
	}

	func string(for ids: [UUID]) -> String {
		invocations.append(.string(ids))
		return stubs.string
	}

	func insertStrings(_ strings: [String], to destination: Destination<UUID>) {
		invocations.append(.insertStrings(strings, destination: destination))
	}

	func insertNodes(_ nodes: [any TreeNode<Item>], to destination: Destination<UUID>) {
		invocations.append(.insertNodes(destination: destination))
	}

	func move(ids: [UUID], to destination: Destination<UUID>) {
		invocations.append(.move(ids, destination: destination))
	}

	func move(ids: [UUID], to target: UUID?) {
		invocations.append(.moveToTarget(ids, target: target))
	}

	func validateMovement(_ ids: [UUID], to destination: Destination<UUID>) -> Bool {
		invocations.append(.validateMovement(ids, destination: destination))
		return stubs.validateMovement
	}
}

// MARK: - Nested data structs
extension ContentUnitInteractorMock {

	enum Action {
		case fetchData
		case newItem(ItemProperties, target: UUID?)
		case deleteItems([UUID])
		case setStatus(Bool, ids: [UUID], moveToEnd: Bool)
		case setSubitemsHidden(Bool, ids: [UUID])
		case setColor(ItemColor?, ids: [UUID])
		case setIcon(IconName?, ids: [UUID])
		case setText(text: String, note: String?, id: UUID)
		case item(UUID)
		case data(UUID)
		case string([UUID])
		case insertStrings([String], destination: Destination<UUID>)
		case insertNodes(destination: Destination<UUID>)
		case move([UUID], destination: Destination<UUID>)
		case moveToTarget([UUID], target: UUID?)
		case validateMovement([UUID], destination: Destination<UUID>)
	}

	struct Stubs {
		var fetchedItem: Item?
		var snapshot = Snapshot<Item>()
		var newItem = UUID()
		var item = Item(text: "")
		var data: Data?
		var string = ""
		var validateMovement = false
	}
}

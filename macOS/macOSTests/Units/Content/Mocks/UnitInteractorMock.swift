//
//  UnitInteractorMock.swift
//  macOSTests
//
//  Created by Anton Cherkasov on 25.01.2025.
//

import Foundation
import CoreModule
import Hierarchy
@testable import Nested_List

final class UnitInteractorMock {

	private(set) var invocations: [Action] = []
	var stubs = Stubs()

	func clear() {
		invocations.removeAll()
	}
}

// MARK: - ContentInteractorProtocol
extension UnitInteractorMock: ContentInteractorProtocol {

	func fetchData() {
		invocations.append(.fetchData)
	}

	func configure(for root: UUID?) {
		invocations.append(.configure(root: root))
	}
	
	func move(_ ids: [UUID], to destination: Destination<UUID>) {
		invocations.append(.move(ids, destination: destination))
	}
	
	func validateMovement(_ ids: [UUID], to destination: Destination<UUID>) -> Bool {
		invocations.append(.validateMovement(ids, destination: destination))
		return stubs.validateMovement
	}
	
	func copy(_ ids: [UUID], to destination: Destination<UUID>) {
		invocations.append(.copy(ids, destination: destination))
	}

	func newItem(with properties: ItemProperties, target: UUID?) -> UUID {
		invocations.append(.newItem(properties, target: target))
		return stubs.newItem
	}

	func setStatus(_ status: Bool, for ids: [UUID], moveToEnd: Bool) {
		invocations.append(.setStatus(status, ids: ids, moveToEnd: moveToEnd))
	}

	func setSubitemsHidden(_ hidden: Bool, for ids: [UUID]) {
		invocations.append(.setSubitemsHidden(hidden, ids: ids))
	}

	func toggleSubitemsHidden(for id: UUID) {
		invocations.append(.toggleSubitemsHidden(id: id))
	}

	func toggleStrikethrough(for id: UUID, moveToEnd: Bool) {
		invocations.append(.toggleStatus(id: id, moveToEnd: moveToEnd))
	}

	func setColor(_ color: ItemColor?, for ids: [UUID]) {
		invocations.append(.setColor(color, ids: ids))
	}

	func setIcon(_ name: IconName?, for ids: [UUID]) {
		invocations.append(.setIcon(name, ids: ids))
	}

	func set(text: String, note: String?, for id: UUID) {
		invocations.append(.setText(text: text, note: note, id: id))
	}

	func set(note: String?, for ids: [UUID]) {
		invocations.append(.setNote(note: note, ids: ids))
	}

	func deleteItems(_ ids: [UUID]) {
		invocations.append(.deleteItems(ids))
	}
	
	func insertStrings(_ strings: [String], to destination: Destination<UUID>) {
		invocations.append(.insertStrings(strings, destination: destination))
	}

	func nodes(for ids: [UUID]) -> [any TreeNode<Item>] {
		invocations.append(.nodes(ids: ids))
		return stubs.nodes
	}

	func insertStrings(_ data: [Data], to destination: Destination<UUID>) {
		invocations.append(.insertStringsFromData(data: data, destination: destination))
	}

	func insertItems(_ data: [Data], to destination: Destination<UUID>) {
		invocations.append(.insertItems(data: data, destination: destination))
	}

	func data(for id: UUID) -> Data? {
		invocations.append(.dataForId(id: id))
		return stubs.data[id]
	}

}

// MARK: - Nested data structs
extension UnitInteractorMock {

	enum Action {
		case fetchData
		case configure(root: UUID?)
		case move(_ ids: [UUID], destination: Destination<UUID>)
		case validateMovement(_ ids: [UUID], destination: Destination<UUID>)
		case copy(_ ids: [UUID], destination: Destination<UUID>)
		case newItem(_ properties: ItemProperties, target: UUID?)
		case setStatus(_ status: Bool, ids: [UUID], moveToEnd: Bool)
		case setSubitemsHidden(_ hidden: Bool, ids: [UUID])
		case toggleSubitemsHidden(id: UUID)
		case toggleStatus(id: UUID, moveToEnd: Bool)
		case setColor(_ color: ItemColor?, ids: [UUID])
		case setIcon(_ name: IconName?, ids: [UUID])
		case setText(text: String, note: String?, id: UUID)
		case setNote(note: String?, ids: [UUID])
		case deleteItems(_ ids: [UUID])
		case insertStrings(_ strings: [String], destination: Destination<UUID>)
		case nodes(ids: [UUID])
		case insertStringsFromData(data: [Data], destination: Destination<UUID>)
		case insertItems(data: [Data], destination: Destination<UUID>)
		case dataForId(id: UUID)
	}

	struct Stubs {
		var validateMovement: Bool = false
		var newItem: UUID = .random
		var nodes: [any TreeNode<Item>] = []
		var data: [UUID: Data] = [:]
	}
}

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
	
	func newItem(_ text: String, target: UUID?) -> UUID {
		invocations.append(.newItem(text, target: target))
		return stubs.newItem
	}
	
	func setStatus(_ status: Bool, for ids: [UUID], moveToEnd: Bool) {
		invocations.append(.setStatus(status, ids: ids, moveToEnd: moveToEnd))
	}

	func toggleStrikethrough(for id: UUID, moveToEnd: Bool) {
		invocations.append(.toggleStatus(id: id, moveToEnd: moveToEnd))
	}

	func setMark(_ isMarked: Bool, for ids: [UUID], moveToTop: Bool) {
		invocations.append(.setMark(isMarked, ids: ids, moveToTop: moveToTop))
	}
	
	func setStyle(_ style: ItemStyle, for ids: [UUID]) {
		invocations.append(.setStyle(style, ids: ids))
	}

	func setColor(_ color: ItemColor, for ids: [UUID]) {
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

	func set(_ text: String, note: String?, isMarked: Bool, style: CoreModule.ItemStyle, for id: UUID) {
		invocations.append(.set(text: text, note: note, isMarked: isMarked, style: style, id: id))
	}

	func deleteItems(_ ids: [UUID]) {
		invocations.append(.deleteItems(ids))
	}
	
	func strings(for ids: [UUID]) -> [String] {
		invocations.append(.strings(ids))
		return stubs.strings
	}
	
	func insertStrings(_ strings: [String], to destination: Destination<UUID>) {
		invocations.append(.insertStrings(strings, destination: destination))
	}

	func nodes(for ids: [UUID]) -> [Node<Item>] {
		invocations.append(.nodes(ids: ids))
		return stubs.nodes
	}

	func insertStrings(_ data: [Data], to destination: Destination<UUID>) {
		invocations.append(.insertStringsFromData(data: data, destination: destination))
	}

	func insertItems(_ data: [Data], to destination: Destination<UUID>) {
		invocations.append(.insertItems(data: data, destination: destination))
	}

}

// MARK: - Nested data structs
extension UnitInteractorMock {

	enum Action {
		case fetchData
		case move(_ ids: [UUID], destination: Destination<UUID>)
		case validateMovement(_ ids: [UUID], destination: Destination<UUID>)
		case copy(_ ids: [UUID], destination: Destination<UUID>)
		case newItem(_ text: String, target: UUID?)
		case setStatus(_ status: Bool, ids: [UUID], moveToEnd: Bool)
		case toggleStatus(id: UUID, moveToEnd: Bool)
		case setMark(_ isMarked: Bool, ids: [UUID], moveToTop: Bool)
		case setStyle(_ style: ItemStyle, ids: [UUID])
		case setColor(_ color: ItemColor, ids: [UUID])
		case setIcon(_ name: IconName?, ids: [UUID])
		case setText(text: String, note: String?, id: UUID)
		case setNote(note: String?, ids: [UUID])
		case deleteItems(_ ids: [UUID])
		case strings(_ ids: [UUID])
		case insertStrings(_ strings: [String], destination: Destination<UUID>)
		case nodes(ids: [UUID])
		case insertStringsFromData(data: [Data], destination: Destination<UUID>)
		case insertItems(data: [Data], destination: Destination<UUID>)
		case set(text: String, note: String?, isMarked: Bool, style: ItemStyle, id: UUID)
	}

	struct Stubs {
		var validateMovement: Bool = false
		var newItem: UUID = .random
		var strings: [String] = []
		var nodes: [Node<Item>] = []
	}
}

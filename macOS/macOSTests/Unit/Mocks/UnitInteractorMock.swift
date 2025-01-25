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
}

// MARK: - UnitInteractorProtocol
extension UnitInteractorMock: UnitInteractorProtocol {

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
	
	func setMark(_ isMarked: Bool, for ids: [UUID]) {
		invocations.append(.setMark(isMarked, ids: ids))
	}
	
	func setStyle(_ style: Item.Style, for ids: [UUID]) {
		invocations.append(.setStyle(style, ids: ids))
	}
	
	func set(text: String, note: String?, for id: UUID) {
		invocations.append(.set(text: text, note: note, id: id))
	}
	
	func deleteNote(for ids: [UUID]) {
		invocations.append(.deleteNote(ids: ids))
	}
	
	func addNote(for ids: [UUID]) {
		invocations.append(.addNote(ids: ids))
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
		case setMark(_ isMarked: Bool, ids: [UUID])
		case setStyle(_ style: Item.Style, ids: [UUID])
		case set(text: String, note: String?, id: UUID)
		case deleteNote(ids: [UUID])
		case addNote(ids: [UUID])
		case deleteItems(_ ids: [UUID])
		case strings(_ ids: [UUID])
		case insertStrings(_ strings: [String], destination: Destination<UUID>)
	}

	struct Stubs {
		var validateMovement: Bool = false
		var newItem: UUID = .random
		var strings: [String] = []
	}
}

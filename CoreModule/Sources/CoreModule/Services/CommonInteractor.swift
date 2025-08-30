//
//  CommonInteractor.swift
//  CoreModule
//
//  Created by Anton Cherkasov on 30.08.2025.
//

import Foundation
import Hierarchy

public protocol CommonInteractorProtocol {
	func newItem(_ text: String, isStrikethrough: Bool?, note: String?, isMarked: Bool, style: ItemStyle, target: UUID?) -> UUID
	func deleteItems(_ ids: [UUID])

	func validateMovement(_ ids: [UUID], to destination: Destination<UUID>) -> Bool
	func move(_ ids: [UUID], to destination: Destination<UUID>)

	func insertStrings(_ strings: [String], to destination: Destination<UUID>)
}

public final class CommonInteractor {

	private let storage: DocumentStorage<Content>

	public init(storage: DocumentStorage<Content>) {
		self.storage = storage
	}
}

// MARK: - CommonInteractorProtocol
extension CommonInteractor: CommonInteractorProtocol {

	public func newItem(_ text: String, isStrikethrough: Bool?, note: String?, isMarked: Bool, style: ItemStyle, target: UUID?) -> UUID {
		var options = ItemOptions()
		if isMarked {
			options.insert(.marked)
		}
		if isStrikethrough == true {
			options.insert(.strikethrough)
		}
		let new = Item(uuid: UUID(), text: text, note: note, options: options, style: style)
		let destination = Destination(target: target)
		storage.modificate { content in
			content.root.insertItems(with: [new], to: destination)
		}
		return new.id
	}

	public func validateMovement(_ ids: [UUID], to destination: Destination<UUID>) -> Bool {
		storage.state.root.validateMoving(ids, to: destination)
	}

	public func move(_ ids: [UUID], to destination: Destination<UUID>) {
		storage.modificate { content in
			content.root.moveItems(with: ids, to: destination)
		}
	}

	public func deleteItems(_ ids: [UUID]) {
		storage.modificate { content in
			content.root.deleteItems(ids)
		}
	}

	public func insertStrings(_ strings: [String], to destination: Destination<UUID>) {
		let parser = Parser()
		let nodes = strings.flatMap { string in
			parser.parse(from: string)
		}
		storage.modificate { content in
			content.root.insertItems(from: nodes, to: destination)
		}
	}
}

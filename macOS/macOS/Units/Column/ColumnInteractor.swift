//
//  ColumnInteractor.swift
//  Nested List
//
//  Created by Anton Cherkasov on 16.08.2025.
//

import Foundation
import Hierarchy
import CoreModule

protocol ColumnInteractorProtocol {
	func fetchData()
	func rootItem() -> Node<Item>?
	@discardableResult
	func newItem(_ text: String, isStrikethrough: Bool, note: String?, isMarked: Bool, style: ItemStyle, target: UUID?) -> UUID
	func set(_ text: String, isStrikethrough: Bool, note: String?, isMarked: Bool, style: ItemStyle)
	func deleteColumn()
}

final class ColumnInteractor {

	let root: UUID

	private let storage: DocumentStorage<Content>

	weak var presenter: ColumnPresenterProtocol?

	// MARK: - Initialization

	init(root: UUID, storage: DocumentStorage<Content>) {
		self.root = root
		self.storage = storage
		storage.addObservation(for: self) { [weak self] _, content in
			guard let item = storage.state.root.node(with: root)?.value else {
				return
			}
			self?.presenter?.present(item)
		}
	}
}

// MARK: - ColumnInteractorProtocol
extension ColumnInteractor: ColumnInteractorProtocol {

	func fetchData() {
		guard let item = storage.state.root.node(with: root)?.value else {
			return
		}
		presenter?.present(item)
	}

	func rootItem() -> Node<Item>? {
		guard let node = storage.state.root.nodes(with: [root]).first else {
			return nil
		}
		return node.map { $0 }
	}

	func newItem(_ text: String, isStrikethrough: Bool, note: String?, isMarked: Bool, style: ItemStyle, target: UUID?) -> UUID {
		var options = ItemOptions()
		if isMarked {
			options.insert(.marked)
		}
		if isStrikethrough {
			options.insert(.strikethrough)
		}
		let new = Item(uuid: UUID(), text: text, note: note, options: options, style: style)
		let destination = Destination(target: target ?? root)
		storage.modificate { content in
			content.root.insertItems(with: [new], to: destination)
		}
		return new.id
	}

	func set(_ text: String, isStrikethrough: Bool, note: String?, isMarked: Bool, style: ItemStyle) {
		storage.modificate { content in
			content.root.setProperty(\.text, to: text, for: [root])
			content.root.setProperty(\.isStrikethrough, to: isStrikethrough, for: [root])
			content.root.setProperty(\.note, to: note, for: [root])
			content.root.setProperty(\.isMarked, to: isMarked, for: [root], downstream: true)
			content.root.setProperty(\.style, to: style, for: [root])
		}
	}

	func deleteColumn() {
		storage.modificate { content in
			content.root.deleteItem(root)
		}
	}
}

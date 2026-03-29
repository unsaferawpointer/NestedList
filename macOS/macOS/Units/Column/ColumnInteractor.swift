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
	func configure(for root: UUID)
	func rootItem() -> Node<Item>?
	@discardableResult
	func newItem(
		_ text: String,
		isStrikethrough: Bool,
		note: String?,
		iconName: IconName?,
		tintColor: ItemColor?,
		target: UUID?
	) -> UUID
	func set(
		_ text: String,
		note: String?,
		iconName: IconName?,
		tintColor: ItemColor?
	)
	func moveForward()
	func validateMovingForward() -> Bool
	func moveBackward()
	func validateMovingBackward() -> Bool
	func deleteColumn()
}

final class ColumnInteractor {

	private var root: UUID

	private let storage: DocumentStorage<Content>

	weak var presenter: ColumnPresenterProtocol?

	var base: CommonInteractorProtocol

	// MARK: - Initialization

	init(root: UUID, storage: DocumentStorage<Content>) {
		self.root = root
		self.storage = storage
		self.base = CommonInteractor(storage: storage)
		storage.addObservation(for: self) { [weak self] content in
			guard let self else {
				return
			}
			guard let item = storage.state.root.node(with: self.root)?.value else {
				return
			}
			self.presenter?.present(item)
		}
	}

	deinit {
		storage.removeObserver(self)
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

	func configure(for root: UUID) {
		self.root = root
		fetchData()
	}

	func rootItem() -> Node<Item>? {
		guard let node = storage.state.root.nodes(with: [root]).first else {
			return nil
		}
		return node.map { $0 }
	}

	func newItem(
		_ text: String,
		isStrikethrough: Bool,
		note: String?,
		iconName: IconName?,
		tintColor: ItemColor?,
		target: UUID?
	) -> UUID {
		return base.newItem(
			text,
			isStrikethrough: isStrikethrough,
			note: note,
			iconName: iconName,
			tintColor: tintColor,
			target: target ?? root
		)
	}

	func set(_ text: String, note: String?, iconName: IconName?, tintColor: ItemColor?) {
		storage.modificate { content in
			content.root.setProperty(\.text, to: text, for: [root])
			content.root.setProperty(\.note, to: note, for: [root])
			content.root.setProperty(\.iconName, to: iconName, for: [root])
			content.root.setProperty(\.tintColor, to: tintColor, for: [root], downstream: true)
		}
	}

	func moveForward() {
		base.moveForward(root)
	}

	func validateMovingForward() -> Bool {
		base.validateMovingForward(root)
	}

	func moveBackward() {
		base.moveBackward(root)
	}

	func validateMovingBackward() -> Bool {
		base.validateMovingBackward(root)
	}

	func deleteColumn() {
		base.deleteItems([root])
	}
}

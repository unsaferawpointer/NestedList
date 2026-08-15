//
//  ColumnInteractor.swift
//  macOS
//

import Foundation
import Hierarchy
import CoreModule

/// The Column interactor interface.
protocol ColumnInteractorProtocol: AnyObject {
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
	func set(_ text: String, note: String?)
	func moveForward()
	func validateMovingForward() -> Bool
	func moveBackward()
	func validateMovingBackward() -> Bool
	func deleteColumn()
}

/// The Column interactor.
final class ColumnInteractor {

	private var root: UUID

	private let storage: DocumentStorage<DocumentContent>

	weak var presenter: (any ColumnPresenterProtocol)?

	var base: CommonInteractorProtocol

	// MARK: - Initialization

	init(root: UUID, storage: DocumentStorage<DocumentContent>) {
		self.root = root
		self.storage = storage
		self.base = CommonInteractor(storage: storage)
		storage.addObservation(for: self) { [weak self] content in
			guard let self else {
				return
			}
			guard let item = storage.state[root] else {
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
		guard let item = storage.state[root] else {
			return
		}
		presenter?.present(item)
	}

	func configure(for root: UUID) {
		self.root = root
		fetchData()
	}

	func rootItem() -> Node<Item>? {
		return nil
//		guard let node = storage.state[root] else {
//			return nil
//		}
//		return node.map { $0 }
	}

	func newItem(
		_ text: String,
		isStrikethrough: Bool,
		note: String?,
		iconName: IconName?,
		tintColor: ItemColor?,
		target: UUID?
	) -> UUID {
//		return base.newItem(
//			text,
//			isStrikethrough: isStrikethrough,
//			note: note,
//			iconName: iconName,
//			tintColor: tintColor,
//			target: target ?? root
//		)
		return UUID()
	}

	func set(_ text: String, note: String?) {
//		storage.modificate { content in
//			content.root.setProperty(\.text, to: text, for: [root])
//			content.root.setProperty(\.note, to: note, for: [root])
//		}
	}

	func moveForward() {
//		base.moveForward(root)
	}

	func validateMovingForward() -> Bool {
//		base.validateMovingForward(root)
		return true
	}

	func moveBackward() {
//		base.moveBackward(root)
	}

	func validateMovingBackward() -> Bool {
//		base.validateMovingBackward(root)
		return true
	}

	func deleteColumn() {
		base.deleteItems([root])
	}
}

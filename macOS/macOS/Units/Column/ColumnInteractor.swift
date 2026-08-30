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
	func rootItem() -> Item?
	@discardableResult
	func newItem(with: ItemProperties, target: UUID?) throws -> UUID
	func set(_ text: String, note: String?)
	func setIcon(_ name: IconName?)
	func setColor(_ color: ItemColor?)
	func toggleStrikethrough(moveToEnd: Bool)
	func isStrikethrough() -> Bool
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
			guard let item = storage.state[self.root] else {
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

	func rootItem() -> Item? {
		storage.state[root]
	}

	func newItem(with properties: ItemProperties, target: UUID?) throws -> UUID {
		return try base.newItem(with: properties, target: target ?? root)
	}

	func set(_ text: String, note: String?) {
		storage.modificate { content in
			content.setProperty(\.text, to: text, for: [root])
			content.setProperty(\.note, to: note, for: [root])
		}
	}

	func setIcon(_ name: IconName?) {
		base.setProperty(\.iconName, to: name, for: [root], downstream: false)
	}

	func setColor(_ color: ItemColor?) {
		base.setProperty(\.tintColor, to: color, for: [root], downstream: false)
	}

	func toggleStrikethrough(moveToEnd: Bool) {
		try? base.toggleStrikethrough(for: root, moveToEnd: moveToEnd)
	}

	func isStrikethrough() -> Bool {
		storage.state[root]?.isStrikethrough ?? false
	}

	func moveForward() {
		try? base.moveForward(id: root)
	}

	func validateMovingForward() -> Bool {
		base.validateMovingForward(id: root)
	}

	func moveBackward() {
		try? base.moveBackward(id: root)
	}

	func validateMovingBackward() -> Bool {
		base.validateMovingBackward(id: root)
	}

	func deleteColumn() {
		base.deleteItems([root])
	}
}

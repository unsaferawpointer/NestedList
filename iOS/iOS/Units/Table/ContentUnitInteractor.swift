//
//  ContentInteractor.swift
//  iOS
//
//  Created by Anton Cherkasov on 22.11.2024.
//

import Foundation
import Hierarchy
import CoreModule

@MainActor
protocol ContentUnitInteractorProtocol {
	func fetchData()

	@discardableResult
	func newItem(_ text: String, note: String?, target: UUID?) -> UUID
	func deleteItems(_ ids: [UUID])
	func setStatus(_ isStrikethrough: Bool, for ids: [UUID], moveToEnd: Bool)
	func setSubitemsHidden(_ hidden: Bool, for ids: [UUID])
	func setColor(_ color: ItemColor?, for ids: [UUID])
	func setIcon(_ name: IconName?, for ids: [UUID])
	func set(_ text: String, note: String?, for id: UUID)
	func item(for id: UUID) -> Item

	func data(of id: UUID) -> Data?
	func string(for ids: [UUID]) -> String
	func insertStrings(_ strings: [String], to destination: Destination<UUID>)
	func insertNodes(_ nodes: [any TreeNode<Item>], to destination: Destination<UUID>)

	func move(ids: [UUID], to destination: Destination<UUID>)
	func move(ids: [UUID], to target: UUID?)
	func validateMovement(_ ids: [UUID], to destination: Destination<UUID>) -> Bool
}

final class ContentUnitInteractor {

	private let storage: DocumentStorage<Content>

	var presenter: ContentPresenterProtocol?

	var base: CommonInteractorProtocol

	// MARK: - Internal State

	private var root: UUID?

	// MARK: - Initialization

	init(root: UUID?, storage: DocumentStorage<Content>) {
		self.storage = storage
		self.base = CommonInteractor(storage: storage)
		self.root = root
		storage.addObservation(for: self) { [weak self] content in
			guard let self else {
				return
			}
			Task { @MainActor [weak self] in
				let snapshot = content.root.snapshot()
					.withRoot(parent: root)
				self?.presenter?.present(snapshot: snapshot)
				if let root, let item = content.root[root] {
					self?.presenter?.presentRoot(item: item)
				}
			}
		}
	}

	deinit {
		storage.removeObserver(self)
	}
}

// MARK: - ContentInteractorProtocol
extension ContentUnitInteractor: ContentUnitInteractorProtocol {

	func fetchData() {
		let snapshot = storage.state.root
			.snapshot()
			.withRoot(parent: root)
		presenter?.present(snapshot: snapshot)
		if let root, let item = storage.state.root[root] {
			presenter?.presentRoot(item: item)
		}
	}

	func newItem(_ text: String, note: String?, target: UUID?) -> UUID {
		let destination = Destination(target: target)
		return base.newItem(
			text,
			isStrikethrough: nil,
			note: note,
			iconName: nil,
			tintColor: nil,
			target: destination.relative(to: root).id
		)
	}

	func item(for id: UUID) -> Item {
		guard let item = storage.state.root[id] else {
			fatalError()
		}
		return item
	}

	func deleteItems(_ ids: [UUID]) {
		base.deleteItems(ids)
	}

	func setStatus(_ isStrikethrough: Bool, for ids: [UUID], moveToEnd: Bool) {
		base.setStatus(isStrikethrough, for: ids, moveToEnd: moveToEnd)
	}

	func setSubitemsHidden(_ hidden: Bool, for ids: [UUID]) {
		base.setProperty(\.isSubitemsHidden, to: hidden, for: ids, downstream: false)
	}

	func setIcon(_ name: IconName?, for ids: [UUID]) {
		base.setProperty(\.iconName, to: name, for: ids, downstream: false)
	}

	func setColor(_ color: ItemColor?, for ids: [UUID]) {
		base.setProperty(\.tintColor, to: color, for: ids, downstream: false)
	}

	func set(_ text: String, note: String?, for id: UUID) {
		base.set(text: text, note: note, for: id)
	}

	func string(for ids: [UUID]) -> String {
		base.string(for: ids)
	}

	func data(of id: UUID) -> Data? {
		base.data(of: id)
	}

	func insertStrings(_ strings: [String], to destination: Destination<UUID>) {
		base.insertStrings(strings, to: destination.relative(to: root))
	}

	func insertNodes(_ nodes: [any TreeNode<Item>], to destination: Destination<UUID>) {
		base.insertNodes(nodes, to: destination.relative(to: root))
	}

	func move(ids: [UUID], to destination: Destination<UUID>) {
		base.move(ids, to: destination.relative(to: root))
	}

	func move(ids: [UUID], to target: UUID?) {
		let destination = Destination(target: target)
		base.move(ids, to: destination)
	}

	func validateMovement(_ ids: [UUID], to destination: Destination<UUID>) -> Bool {
		base.validateMovement(ids, to: destination.relative(to: root))
	}
}

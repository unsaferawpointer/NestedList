//
//  ContentInteractor.swift
//  macOS
//
//  Created by Anton Cherkasov on 16.11.2024.
//

import Foundation
import Hierarchy
import CoreModule

protocol ContentInteractorProtocol {

	func fetchData()

	func move(_ ids: [UUID], to destination: Destination<UUID>)
	func validateMovement(_ ids: [UUID], to destination: Destination<UUID>) -> Bool

	func copy(_ ids: [UUID], to destination: Destination<UUID>)

	@discardableResult
	func newItem(
		_ text: String,
		isStrikethrough: Bool,
		note: String?,
		iconName: IconName?,
		tintColor: ItemColor?,
		target: UUID?
	) -> UUID
	func setStatus(_ status: Bool, for ids: [UUID], moveToEnd: Bool)
	func toggleStrikethrough(for id: UUID, moveToEnd: Bool)
	func setSubitemsHidden(_ hidden: Bool, for ids: [UUID])
	func setColor(_ color: ItemColor?, for ids: [UUID])
	func setIcon(_ name: IconName?, for ids: [UUID])
	func set(text: String, note: String?, for id: UUID)
	func set(note: String?, for ids: [UUID])
	func deleteItems(_ ids: [UUID])

	func insertStrings(_ strings: [String], to destination: Destination<UUID>)

	func nodes(for ids: [UUID]) -> [any TreeNode<Item>]
	func data(for id: UUID) -> Data?

	func insertStrings(_ data: [Data], to destination: Destination<UUID>)
	func insertItems(_ data: [Data], to destination: Destination<UUID>)
}

@MainActor final class ContentInteractor {

	private let storage: DocumentStorage<Content>

	weak var presenter: ContentPresenterProtocol?

	var base: CommonInteractorProtocol

	// MARK: - Internal State

	private var root: UUID?

	// MARK: - Initialization

	init(storage: DocumentStorage<Content>, root: UUID? = nil) {
		self.storage = storage
		self.base = CommonInteractor(storage: storage)
		self.root = root
		storage.addObservation(for: self) { [weak self] content in
			guard let self else {
				return
			}
			if let id = root {
				if let item = content.root[id] {
					self.presenter?.presentRoot(item: item)
				} else {
					self.presenter?.close()
					return
				}
			}
			let snapshot = content.root
				.snapshot()
				.withRoot(parent: self.root)
			self.presenter?.present(snapshot)
		}
	}

	deinit {
		storage.removeObserver(self)
	}
}

// MARK: - ContentInteractorProtocol
extension ContentInteractor: ContentInteractorProtocol {

	func fetchData() {
		let snapshot = storage.state.root
			.snapshot()
			.withRoot(parent: root)
		presenter?.present(snapshot)
		if let id = root, let item = storage.state.root[id] {
			self.presenter?.presentRoot(item: item)
		}
	}

	func move(_ ids: [UUID], to destination: Destination<UUID>) {
		base.move(ids, to: destination.relative(to: root))
	}

	func validateMovement(_ ids: [UUID], to destination: Destination<UUID>) -> Bool {
		base.validateMovement(ids, to: destination.relative(to: root))
	}

	func copy(_ ids: [UUID], to destination: Destination<UUID>) {
		base.copy(ids, to: destination.relative(to: root))
	}

	func newItem(
		_ text: String,
		isStrikethrough: Bool,
		note: String?,
		iconName: IconName?,
		tintColor: ItemColor?,
		target: UUID?
	) -> UUID {
		let destination = Destination(target: target)
		return base.newItem(
			text,
			isStrikethrough: isStrikethrough,
			note: note,
			iconName: iconName,
			tintColor: tintColor,
			target: destination.relative(to: root).id
		)
	}

	func setStatus(_ status: Bool, for ids: [UUID], moveToEnd: Bool) {
		base.setStatus(status, for: ids, moveToEnd: moveToEnd)
	}

	func toggleStrikethrough(for id: UUID, moveToEnd: Bool) {
		base.toggleStrikethrough(for: id, moveToEnd: moveToEnd)
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

	func set(text: String, note: String?, for id: UUID) {
		base.set(text: text, note: note, for: id)
	}

	func deleteItems(_ ids: [UUID]) {
		base.deleteItems(ids)
	}

	func insertStrings(_ strings: [String], to destination: Destination<UUID>) {
		base.insertStrings(strings, to: destination.relative(to: root))
	}

	func set(note: String?, for ids: [UUID]) {
		base.setProperty(\.note, to: note, for: ids, downstream: false)
	}

	func insertStrings(_ data: [Data], to destination: Destination<UUID>) {
		let strings = data.compactMap {
			String(data: $0, encoding: .utf8)
		}
		base.insertStrings(strings, to: destination.relative(to: root))
	}

	func insertItems(_ data: [Data], to destination: Destination<UUID>) {
		base.insertItems(data, to: destination.relative(to: root))
	}

	func nodes(for ids: [UUID]) -> [any TreeNode<Item>] {
		base.nodes(for: ids)
	}

	func data(for id: UUID) -> Data? {
		base.data(of: id)
	}
}

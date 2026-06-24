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

	func strings(for ids: [UUID]) -> [String]
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
		storage.modificate { content in
			content.root.copy(ids: ids, to: destination.relative(to: root))
		}
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
		storage.modificate { content in
			content.root.setProperty(\.isStrikethrough, to: status, for: ids, downstream: true)
			if moveToEnd && status {
				content.root.moveToEnd(ids)
			}
		}
	}

	func toggleStrikethrough(for id: UUID, moveToEnd: Bool) {
		storage.modificate { content in
			let status = content.root.allMatch(id: id, keyPath: \.isStrikethrough, equalsTo: true)
			content.root.setProperty(\.isStrikethrough, to: !status, for: [id], downstream: true)
			if moveToEnd && status == false {
				content.root.moveToEnd([id])
			}
		}
	}

	func setSubitemsHidden(_ hidden: Bool, for ids: [UUID]) {
		storage.modificate { content in
			content.root.setProperty(\.isSubitemsHidden, to: hidden, for: ids)
		}
	}

	func setIcon(_ name: IconName?, for ids: [UUID]) {
		storage.modificate { content in
			content.root.setProperty(\.iconName, to: name, for: ids)
		}
	}

	func setColor(_ color: ItemColor?, for ids: [UUID]) {
		storage.modificate { content in
			content.root.setProperty(\.tintColor, to: color, for: ids)
		}
	}

	func set(text: String, note: String?, for id: UUID) {
		storage.modificate { content in
			content.root.setProperty(\.text, to: text, for: [id])
			content.root.setProperty(\.note, to: note, for: [id])
		}
	}

	func deleteItems(_ ids: [UUID]) {
		base.deleteItems(ids)
	}

	func strings(for ids: [UUID]) -> [String] {

		let copied = storage.state.root.copiedDisjointSubtrees(with: ids)
		let parser = Parser()

		return copied.map { node in
			parser.format(node)
		}
	}

	func insertStrings(_ strings: [String], to destination: Destination<UUID>) {
		base.insertStrings(strings, to: destination.relative(to: root))
	}

	func set(note: String?, for ids: [UUID]) {
		storage.modificate { content in
			content.root.setProperty(\.note, to: note, for: ids)
		}
	}

	func insertStrings(_ data: [Data], to destination: Hierarchy.Destination<UUID>) {
		let strings = data.compactMap {
			String(data: $0, encoding: .utf8)
		}
		self.insertStrings(strings, to: destination.relative(to: root))
	}

	func insertItems(_ data: [Data], to destination: Destination<UUID>) {
		storage.modificate { content in
			content.root.insertItems(from: data, to: destination.relative(to: root))
		}
	}

	func nodes(for ids: [UUID]) -> [any TreeNode<Item>] {
		return storage.state.root.copiedDisjointSubtrees(with: ids)
	}

	func data(for id: UUID) -> Data? {
		storage.state.root.encode(id: id)
	}
}

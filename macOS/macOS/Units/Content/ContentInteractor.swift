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
	func configure(for root: UUID?)

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
	func setColor(_ color: ItemColor, for ids: [UUID])
	func setIcon(_ name: IconName?, for ids: [UUID])
	func set(text: String, note: String?, for id: UUID)
	func set(note: String?, for ids: [UUID])
	func set(
		_ text: String,
		isStrikethrough: Bool,
		note: String?,
		iconName: IconName?,
		tintColor: ItemColor?,
		for id: UUID
	)
	func deleteItems(_ ids: [UUID])

	func strings(for ids: [UUID]) -> [String]
	func insertStrings(_ strings: [String], to destination: Destination<UUID>)

	func nodes(for ids: [UUID]) -> [Node<Item>]

	func insertStrings(_ data: [Data], to destination: Destination<UUID>)
	func insertItems(_ data: [Data], to destination: Destination<UUID>)
}

final class ContentInteractor {

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
			let nodes = content.root.children(of: self.root)
			MainActor.assumeIsolated {
				self.presenter?.present(nodes)
			}
		}
	}

	deinit {
		storage.removeObserver(self)
	}
}

// MARK: - ContentInteractorProtocol
extension ContentInteractor: ContentInteractorProtocol {

	func fetchData() {
		let nodes = storage.state.root.children(of: root)
		MainActor.assumeIsolated { [weak self] in
			self?.presenter?.present(nodes)
		}
	}

	func configure(for root: UUID?) {
		self.root = root
		fetchData()
	}

	func move(_ ids: [UUID], to destination: Destination<UUID>) {
		base.move(ids, to: destination.relative(to: root))
	}

	func validateMovement(_ ids: [UUID], to destination: Destination<UUID>) -> Bool {
		base.validateMovement(ids, to: destination.relative(to: root))
	}

	func copy(_ ids: [UUID], to destination: Destination<UUID>) {
		let nodes = storage.state.root.nodes(with: ids)
		let copied = nodes.map { node in
			node.map { item in
				item.copy()
			}
		}
		storage.modificate { content in
			content.root.insertItems(from: copied, to: destination.relative(to: root))
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
			let status = content.root.node(with: id)?.value.isStrikethrough ?? false
			content.root.setProperty(\.isStrikethrough, to: !status, for: [id], downstream: true)
			if moveToEnd && status == false {
				content.root.moveToEnd([id])
			}
		}
	}

	func setIcon(_ name: IconName?, for ids: [UUID]) {
		storage.modificate { content in
			for node in content.root.nodes(with: ids) {
				node.value.iconName = name
			}
		}
	}

	func setColor(_ color: ItemColor, for ids: [UUID]) {
		storage.modificate { content in
			for node in content.root.nodes(with: ids) {
				node.value.tintColor = color
			}
		}
	}

	func set(text: String, note: String?, for id: UUID) {
		storage.modificate { content in
			content.root.setProperty(\.text, to: text, for: [id])
			content.root.setProperty(\.note, to: note, for: [id])
		}
	}

	func set(
		_ text: String,
		isStrikethrough: Bool,
		note: String?,
		iconName: IconName?,
		tintColor: ItemColor?,
		for id: UUID
	) {
		storage.modificate { content in
			content.root.setProperty(\.text, to: text, for: [id])
			content.root.setProperty(\.isStrikethrough, to: isStrikethrough, for: [id])
			content.root.setProperty(\.note, to: note, for: [id])
			content.root.setProperty(\.iconName, to: iconName, for: [id])
			content.root.setProperty(\.tintColor, to: tintColor, for: [id])
		}
	}

	func deleteItems(_ ids: [UUID]) {
		base.deleteItems(ids)
	}

	func strings(for ids: [UUID]) -> [String] {

		let cache = Set(ids)

		let nodes = storage.state.root.nodes(with: ids)
		let copied = nodes.map { node in
			node.map { $0 }
		}

		copied.forEach { node in
			node.deleteDescendants(with: cache)
		}

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
		let decoder = JSONDecoder()
		let nodes = data.compactMap {
			try? decoder.decode(Node<Item>.self, from: $0)
		}
		storage.modificate { content in
			content.root.insertItems(from: nodes, to: destination.relative(to: root))
		}
	}

	func nodes(for ids: [UUID]) -> [Node<Item>] {
		let cache = Set(ids)

		let nodes = storage.state.root.nodes(with: ids)
		let copied = nodes.map { node in
			node.map { $0 }
		}

		copied.forEach { node in
			node.deleteDescendants(with: cache)
		}

		return copied
	}
}

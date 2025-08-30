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
	func newItem(_ text: String, isStrikethrough: Bool, note: String?, isMarked: Bool, style: ItemStyle, target: UUID?) -> UUID
	func setStatus(_ status: Bool, for ids: [UUID], moveToEnd: Bool)
	func toggleStrikethrough(for id: UUID, moveToEnd: Bool)
	func setMark(_ isMarked: Bool, for ids: [UUID], moveToTop: Bool)
	func setStyle(_ style: ItemStyle, for ids: [UUID])
	func setColor(_ color: ItemColor, for ids: [UUID])
	func setIcon(_ name: IconName?, for ids: [UUID])
	func set(text: String, note: String?, for id: UUID)
	func set(note: String?, for ids: [UUID])
	func set(
		_ text: String,
		isStrikethrough: Bool,
		note: String?,
		isMarked: Bool,
		style: ItemStyle,
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
		storage.addObservation(for: self) { [weak self] _, content in
			guard let self else {
				return
			}
			let nodes = content.root.children(of: root)
			self.presenter?.present(nodes)
		}
	}
}

// MARK: - ContentInteractorProtocol
extension ContentInteractor: ContentInteractorProtocol {

	func fetchData() {
		let nodes = storage.state.root.children(of: root)
		presenter?.present(nodes)
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

	func newItem(_ text: String, isStrikethrough: Bool, note: String?, isMarked: Bool, style: ItemStyle, target: UUID?) -> UUID {
		return base.newItem(
			text,
			isStrikethrough: isStrikethrough,
			note: note,
			isMarked: isMarked,
			style: style,
			target: target
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

	func setMark(_ isMarked: Bool, for ids: [UUID], moveToTop: Bool) {
		storage.modificate { content in
			content.root.setProperty(\.isMarked, to: isMarked, for: ids, downstream: true)
			if moveToTop && isMarked {
				content.root.moveToTop(ids)
			}
		}
	}

	func setStyle(_ style: ItemStyle, for ids: [UUID]) {
		storage.modificate { content in
			content.root.setProperty(\.style, to: style, for: ids, downstream: false)
		}
	}

	func setIcon(_ name: IconName?, for ids: [UUID]) {
		storage.modificate { content in
			for node in content.root.nodes(with: ids) {
				guard case let .section(icon) = node.value.style else {
					continue
				}
				guard let name else {
					node.value.style = .section(icon: nil)
					continue
				}
				if var icon {
					icon.name = name
					node.value.style = .section(icon: icon)
				} else {
					node.value.style = .section(icon: .init(name: name, color: .tertiary))
				}
			}
		}
	}

	func setColor(_ color: ItemColor, for ids: [UUID]) {
		storage.modificate { content in
			for node in content.root.nodes(with: ids) {
				guard case var .section(icon) = node.value.style else {
					continue
				}
				icon?.color = color
				node.value.style = .section(icon: icon)
			}
		}
	}

	func set(text: String, note: String?, for id: UUID) {
		storage.modificate { content in
			content.root.setProperty(\.text, to: text, for: [id])
			content.root.setProperty(\.note, to: note, for: [id])
		}
	}

	func set(_ text: String, isStrikethrough: Bool, note: String?, isMarked: Bool, style: ItemStyle, for id: UUID) {
		storage.modificate { content in
			content.root.setProperty(\.text, to: text, for: [id])
			content.root.setProperty(\.isStrikethrough, to: isStrikethrough, for: [id])
			content.root.setProperty(\.note, to: note, for: [id])
			content.root.setProperty(\.isMarked, to: isMarked, for: [id], downstream: true)
			content.root.setProperty(\.style, to: style, for: [id])
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

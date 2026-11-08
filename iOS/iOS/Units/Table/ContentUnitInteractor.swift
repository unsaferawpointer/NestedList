//
//  ContentInteractor.swift
//  iOS
//
//  Created by Anton Cherkasov on 22.11.2024.
//

import Foundation
import Hierarchy
import CoreModule
import CorePresentation

@MainActor
protocol ContentUnitInteractorProtocol {
	func fetchData() -> (Item?, Snapshot<Item>)
	func focus(on id: UUID?) -> (Item?, Snapshot<Item>)
	func pathItems() -> [Item?]

	@discardableResult
	func newItem(with properties: ItemProperties, target: UUID?) throws -> UUID
	@discardableResult
	func createMirror(reference: UUID, target: UUID?) throws -> UUID
	func mirrorSourceIDs(to destination: Destination<UUID>) -> Set<UUID>
	func deleteItems(_ ids: [UUID])
	func setStatus(_ isStrikethrough: Bool, for ids: [UUID], moveToEnd: Bool)
	func setSubitemsHidden(_ hidden: Bool, for ids: [UUID])
	func setColor(_ color: ItemColor?, for ids: [UUID])
	func setIcon(_ name: IconName?, for ids: [UUID])
	func set(_ text: String, note: String?, for id: UUID)
	func item(for id: UUID) -> Item

	func nodes(for ids: [UUID]) -> [any TreeNode<Item>]
	func data(of id: UUID) -> Data?
	func string(for ids: [UUID]) -> String
	func insertStrings(_ strings: [String], to destination: Destination<UUID>)
	func insertNodes(_ nodes: [any TreeNode<Item>], to destination: Destination<UUID>)
	func insertItems(_ data: [Data], to destination: Destination<UUID>)
	func insertStrings(_ data: [Data], to destination: Destination<UUID>)


	func move(ids: [UUID], to destination: Destination<UUID>)
	func move(ids: [UUID], to target: UUID?)
	func validateMovement(_ ids: [UUID], to destination: Destination<UUID>) -> Bool
}

final class ContentUnitInteractor {

	private let storage: DocumentStorage<DocumentContent>

	weak var presenter: ContentPresenterProtocol?

	var base: CommonInteractorProtocol

	// MARK: - Internal State

	private var resolver: NavigationResolver

	// MARK: - Initialization

	init(root: UUID?, storage: DocumentStorage<DocumentContent>) {
		self.storage = storage
		self.base = CommonInteractor(storage: storage)
		self.resolver = NavigationResolver(path: .init(root: root))
		storage.addObservation(for: self) { [weak self] _ in
			Task { @MainActor [weak self] in
				guard let self else {
					return
				}
				let (item, snapshot) = fetchData()
				presenter?.present(snapshot: snapshot)
				if let item {
					presenter?.presentRoot(item: item)
				}
				presenter?.presentPath(pathItems())
			}
		}
	}

	deinit {
		storage.removeObserver(self)
	}
}

// MARK: - ContentInteractorProtocol
extension ContentUnitInteractor: ContentUnitInteractorProtocol {

	func fetchData() -> (Item?, Snapshot<Item>) {
		resolvePath()
		let snapshot = storage.state
			.snapshot()
			.withRoot(parent: focusedRoot)
		guard let id = resolver.path.root, let item = storage.state[id] else {
			return (nil, snapshot)
		}
		return (item, snapshot)
	}

	func focus(on id: UUID?) -> (Item?, Snapshot<Item>) {
		resolvePath()
		guard let id else {
			resolver = NavigationResolver(path: .init(root: resolver.path.root))
			return fetchData()
		}
		guard storage.state[id]?.isMirror == false else {
			return fetchData()
		}
		try? resolver.focus(on: id, in: storage.state)
		return fetchData()
	}

	func pathItems() -> [Item?] {
		resolvePath()
		return resolver.items(in: storage.state)
	}

	func newItem(with properties: ItemProperties, target: UUID?) throws -> UUID {
		let destination = Destination(target: target)
		return try base.newItem(with: properties, target: destination.relative(to: focusedRoot).id)
	}

	func createMirror(reference: UUID, target: UUID?) throws -> UUID {
		let destination = Destination(target: target)
		return try base.createMirror(reference: reference, target: destination.relative(to: focusedRoot).id)
	}

	func mirrorSourceIDs(to destination: Destination<UUID>) -> Set<UUID> {
		base.mirrorSourceIDs(to: destination.relative(to: focusedRoot))
	}

	func item(for id: UUID) -> Item {
		guard let item = storage.state[id] else {
			fatalError()
		}
		return item
	}

	func deleteItems(_ ids: [UUID]) {
		base.deleteItems(ids)
	}

	func setStatus(_ isStrikethrough: Bool, for ids: [UUID], moveToEnd: Bool) {
		try? base.setStatus(isStrikethrough, for: ids, moveToEnd: moveToEnd)
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

	func nodes(for ids: [UUID]) -> [any TreeNode<Item>] {
		base.nodes(for: ids)
	}

	func data(of id: UUID) -> Data? {
		base.data(of: id)
	}

	func insertStrings(_ strings: [String], to destination: Destination<UUID>) {
		try? base.insertStrings(strings, to: destination.relative(to: focusedRoot))
	}

	func insertNodes(_ nodes: [any TreeNode<Item>], to destination: Destination<UUID>) {
		try? base.insertNodes(nodes, to: destination.relative(to: focusedRoot))
	}

	func insertStrings(_ data: [Data], to destination: Hierarchy.Destination<UUID>) {
		let strings = data.compactMap {
			String(data: $0, encoding: .utf8)
		}
		try? base.insertStrings(strings, to: destination.relative(to: focusedRoot))
	}

	func insertItems(_ data: [Data], to destination: Hierarchy.Destination<UUID>) {
		try? base.insertItems(data, to: destination.relative(to: focusedRoot))
	}

	func move(ids: [UUID], to destination: Destination<UUID>) {
		try? base.move(ids, to: destination.relative(to: focusedRoot))
	}

	func move(ids: [UUID], to target: UUID?) {
		let destination = Destination(target: target)
		try? base.move(ids, to: destination)
	}

	func validateMovement(_ ids: [UUID], to destination: Destination<UUID>) -> Bool {
		base.validateMovement(ids, to: destination.relative(to: focusedRoot))
	}
}

// MARK: - Private methods
private extension ContentUnitInteractor {

	var focusedRoot: UUID? {
		resolvePath()
		return resolver.focused
	}

	func resolvePath() {
		do {
			try resolver.resolve(content: storage.state)
		} catch {
			resolver = NavigationResolver()
		}
	}
}

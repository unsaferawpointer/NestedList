//
//  ContentPresenter.swift
//  iOS
//
//  Created by Anton Cherkasov on 22.11.2024.
//

import Foundation
import UIKit

import Hierarchy
import CoreModule
import DesignSystem
import CoreSettings

protocol UnitPresenterProtocol: AnyObject {
	func present(_ content: Content)
}

final class UnitPresenter {

	var interactor: UnitInteractorProtocol?

	weak var view: UnitView?

	private(set) var factory: ItemsFactoryProtocol = ItemsFactory()

	private(set) var menuFactory = MenuFactory()

	var settingsProvider: any StateProviderProtocol<Settings>

	var toolbarFactory = ToolbarFactory()

	var editingMode: EditingMode? {
		didSet {
			let selection = view?.selection ?? []
			let model = toolbarFactory.build(
				editingMode: editingMode,
				selectedCount: selection.count,
				isCompleted: cache.validate(.isStrikethrough, other: selection),
				isMarked: cache.validate(.isMarked, other: selection),
				isSection: cache.validate(.isSection, other: selection)
			)
			view?.display(model)
			view?.setEditing(editingMode)
		}
	}

	// MARK: - Cache

	var cache = Cache<Property, Item>()

	// MARK: - Initialization

	init(settingsProvider: any StateProviderProtocol<Settings> = SettingsProvider.shared) {
		self.settingsProvider = settingsProvider

		settingsProvider.addObservation(for: self) { [weak self] _, settings in
			self?.interactor?.fetchData()
		}
	}
}

// MARK: - ContentPresenterProtocol
extension UnitPresenter: UnitPresenterProtocol {

	func present(_ content: Content) {

		var snapshot = Snapshot(content.root.nodes)
		snapshot.validate(keyPath: \.isStrikethrough)
		snapshot.validate(keyPath: \.isMarked)

		cache.store(.isStrikethrough, keyPath: \.isStrikethrough, equalsTo: true, from: snapshot)
		cache.store(.isMarked, keyPath: \.isMarked, equalsTo: true, from: snapshot)
		cache.store(property: .isSection, from: snapshot) { item in
			item.style.isSection
		}

		let converted = snapshot
			.map { info in

				let isGroup = (content.root.node(with: info.model.id)?.children ?? []).contains { node in
					node.value.style.isSection
				}

				return factory.makeItem(
					item: info.model,
					level: info.level,
					isGroup: isGroup,
					iconColor: settingsProvider.state.iconColor
				)
			}
		view?.display(converted)
	}
}

// MARK: - ViewDelegate
extension UnitPresenter: ViewDelegate {

	func viewDidChange(state: ViewState) {
		guard case .didAppear = state else {
			return
		}
		interactor?.fetchData()
		view?.expandAll()

		let toolbar = toolbarFactory.build(
			editingMode: editingMode,
			selectedCount: 0,
			isCompleted: cache.validate(.isStrikethrough, other: view?.selection ?? []),
			isMarked: cache.validate(.isMarked, other: view?.selection ?? []),
			isSection: cache.validate(.isSection, other: view?.selection ?? [])
		)
		view?.display(toolbar)
	}
}

// MARK: - InteractionDelegate
extension UnitPresenter: InteractionDelegate {

	func userDidSelect(item: String, with selection: [UUID]?) {
		guard let menuIdentifier = ElementIdentifier(rawValue: item) else {
			return
		}

		let currentSelection = selection ?? view?.selection

		switch menuIdentifier {
		case .edit:
			editingMode = nil
			guard let id = currentSelection?.first, let item = interactor?.item(for: id) else {
				return
			}
			let model = DetailsView.Model(navigationTitle: "Edit Item", properties: item.details)
			view?.showDetails(with: model) { [weak self] saved, success in
				self?.view?.hideDetails()
				if success {
					let note = saved.description.isEmpty ? nil : saved.description
					self?.interactor?.set(saved.text, note: note, isMarked: saved.isMarked, style: saved.style, for: id)
				}
			}
		case .new:
			editingMode = nil
			createNew(target: currentSelection?.first)
		case .cut:
			editingMode = nil
			guard let interactor else {
				return
			}
			let string = interactor.string(for: currentSelection ?? [])
			UIPasteboard.general.string = string
			interactor.deleteItems(currentSelection ?? [])
		case .copy:
			editingMode = nil
			guard let interactor else {
				return
			}
			let string = interactor.string(for: currentSelection ?? [])
			UIPasteboard.general.string = string
		case .paste:
			editingMode = nil
			guard let string = UIPasteboard.general.string, let target = currentSelection?.first else {
				return
			}
			interactor?.insertStrings([string], to: .onItem(with: target))
		case .delete:
			editingMode = nil
			interactor?.deleteItems(currentSelection ?? [])
		case .completed:
			editingMode = nil
			let moveToEnd = settingsProvider.state.completionBehaviour == .moveToEnd
			let newValue = !(cache.validate(.isStrikethrough, other: currentSelection ?? []) ?? false)
			interactor?.setStatus(newValue, for: currentSelection ?? [], moveToEnd: moveToEnd)
		case .marked:
			editingMode = nil
			let moveToTop = settingsProvider.state.markingBehaviour == .moveToTop
			let newValue = !(cache.validate(.isMarked, other: currentSelection ?? []) ?? false)
			interactor?.mark(newValue, ids: currentSelection ?? [], moveToTop: moveToTop)
		case .style:
			editingMode = nil
			let newValue = !(cache.validate(.isSection, other: currentSelection ?? []) ?? false)
			interactor?.setStyle(newValue ? .section(icon: nil) : .item, for: currentSelection ?? [])
		case .select:
			editingMode = .selection
		case .reorder:
			editingMode = .reordering
		case .settings:
			view?.showSettings()
		case .done:
			editingMode = nil
		case .expandAll:
			view?.expandAll()
		case .collapseAll:
			view?.collapseAll()
		}
	}
}

// MARK: - UnitViewDelegate
extension UnitPresenter: UnitViewDelegate { }

// MARK: - ListDelegate
extension UnitPresenter: ListDelegate {

	func listItemHasBeenDelete(id: UUID) {
		interactor?.deleteItems([id])
	}

	func listDidChangeSelection(ids: [UUID]) {
		let toolbar = toolbarFactory.build(
			editingMode: editingMode,
			selectedCount: ids.count,
			isCompleted: cache.validate(.isStrikethrough, other: ids),
			isMarked: cache.validate(.isMarked, other: ids),
			isSection: cache.validate(.isSection, other: ids)
		)
		view?.display(toolbar)
	}

	func menu(for ids: [UUID]) -> [MenuElement] {
		menuFactory.build(
			isCompleted: cache.validate(.isStrikethrough, other: ids),
			isMarked: cache.validate(.isMarked, other: ids),
			isSection: cache.validate(.isSection, other: ids)
		)
	}
}

import UniformTypeIdentifiers

// MARK: - DropDelegate
extension UnitPresenter: DropDelegate {

	typealias ID = UUID

	func move(_ ids: [UUID], to destination: Destination<UUID>) {
		interactor?.move(ids: ids, to: destination)
		if let target = destination.id {
			view?.expand(target)
		}
	}
	
	func validateMovement(_ ids: [UUID], to destination: Destination<UUID>) -> Bool {
		interactor?.validateMovement(ids, to: destination) ?? false
	}

	func availableTypes() -> [String] {
		return [UTType.plainText.identifier]
	}

	func drop(_ strings: [String], to destination: Destination<UUID>) {
		interactor?.insertStrings(strings, to: destination)
	}

	func string(for id: UUID) -> String {
		return interactor?.string(for: [id]) ?? ""
	}

}

// MARK: - Helpers
private extension UnitPresenter {

	func createNew(target: UUID?) {
		let model = DetailsView.Model(navigationTitle: "New Item", properties: .init(text: ""))
		view?.showDetails(with: model) { [weak self] saved, success in
			self?.view?.hideDetails()
			if success {
				let note = saved.description.isEmpty ? nil : saved.description
				guard let id = self?.interactor?.newItem(
					saved.text,
					note: note,
					isMarked: saved.isMarked,
					style: saved.style,
					target: target
				) else {
					return
				}
				if let target {
					self?.view?.expand(target)
				}
				self?.view?.scroll(to: id)
			}
		}
	}
}

enum Property: Hashable {
	case isStrikethrough
	case isMarked
	case isItem
	case isSection
}

private extension Item {

	var details: DetailsView.Properties {
		return .init(
			text: text,
			description: note ?? "",
			isMarked: isMarked,
			style: style
		)
	}
}

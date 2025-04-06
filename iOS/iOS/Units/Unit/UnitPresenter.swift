//
//  UnitPresenter.swift
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

	var settingsProvider: any StateProviderProtocol<Settings>

	var toolbarFactory = ToolbarFactory()

	var editingMode: EditingMode? {
		didSet {
			let selection = view?.selection ?? []
			let model = toolbarFactory.build(
				editingMode: editingMode,
				selectedCount: selection.count
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

// MARK: - UnitPresenterProtocol
extension UnitPresenter: UnitPresenterProtocol {

	func present(_ content: Content) {

		var snapshot = Snapshot(content.root.nodes)
		snapshot.validate(keyPath: \.isDone)
		snapshot.validate(keyPath: \.isMarked)

		cache.store(.isDone, keyPath: \.isDone, equalsTo: true, from: snapshot)
		cache.store(.isMarked, keyPath: \.isMarked, equalsTo: true, from: snapshot)
		cache.store(.isSection, keyPath: \.style, equalsTo: .section, from: snapshot)

		let converted = snapshot
			.map { info in
				factory.makeItem(
					item: info.model,
					level: info.level,
					sectionStyle: settingsProvider.state.sectionStyle
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

		let toolbar = toolbarFactory.build(editingMode: editingMode, selectedCount: 0)
		view?.display(toolbar)
	}
}

// MARK: - ToolbarDelegate
extension UnitPresenter: ToolbarDelegate {

	func toolbarDidSelect() {
		editingMode = .selection
	}
	
	func toolbarDidReorder() {
		editingMode = .reordering
	}
	
	func toolbarDidOpenSettings() {
		view?.showSettings()
	}

	func toolbarDidFinish() {
		editingMode = nil
	}

	func toolbarDidCreateNew() {
		createNew(target: nil)
	}

	func toolbarDidDelete() {
		guard let selection = view?.selection else {
			return
		}
		editingMode = nil
		interactor?.deleteItems(selection)
	}

	func toolbarDidMarkAsComplete() {
		guard let selection = view?.selection else {
			return
		}
		editingMode = nil
		let moveToEnd = settingsProvider.state.completionBehaviour == .moveToEnd
		interactor?.setStatus(true, for: selection, moveToEnd: moveToEnd)
	}
}

// MARK: - MenuDelegate
extension UnitPresenter: MenuDelegate {

	func menuDidSelect(item: String, with selection: [UUID]) {
		guard let menuIdentifier = ElementIdentifier(rawValue: item) else {
			return
		}

		switch menuIdentifier {
		case .edit:
			guard let id = selection.first, let item = interactor?.item(for: id) else {
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
			createNew(target: selection.first)
		case .cut:
			guard let first = selection.first, let interactor else {
				return
			}
			let string = interactor.string(for: first)
			UIPasteboard.general.string = string
			interactor.deleteItems(selection)
		case .copy:
			guard let first = selection.first, let interactor else {
				return
			}
			let string = interactor.string(for: first)
			UIPasteboard.general.string = string
		case .paste:
			guard let string = UIPasteboard.general.string, let target = selection.first else {
				return
			}
			interactor?.insertStrings([string], to: .onItem(with: target))
		case .delete:
			interactor?.deleteItems(selection)
		case .completed:
			let moveToEnd = settingsProvider.state.completionBehaviour == .moveToEnd
			let newValue = !(cache.validate(.isDone, other: selection) ?? false)
			interactor?.setStatus(newValue, for: selection, moveToEnd: moveToEnd)
		case .marked:
			let moveToTop = settingsProvider.state.markingBehaviour == .moveToTop
			let newValue = !(cache.validate(.isMarked, other: selection) ?? false)
			interactor?.mark(newValue, ids: selection, moveToTop: moveToTop)
		case .style:
			guard let id = selection.first else {
				return
			}
			let newValue = !(cache.validate(.isSection, other: selection) ?? false)
			interactor?.setStyle(newValue ? .section : .item, for: id)
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
			selectedCount: ids.count
		)
		view?.display(toolbar)
	}

	func menu(for ids: [UUID]) -> [MenuElement] {
		return MenuFactory.build(
			isCompleted: cache.validate(.isDone, other: ids),
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
		return interactor?.string(for: id) ?? ""
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
				self?.interactor?.newItem(
					saved.text,
					note: note,
					isMarked: saved.isMarked,
					style: saved.style,
					target: target
				)
				if let target {
					self?.view?.expand(target)
				}
			}
		}
	}
}

enum Property: Hashable {
	case isDone
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

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

protocol ContentPresenterProtocol: AnyObject {
	func present(_ content: Content)
	func present(_ nodes: [Node<Item>])
}

final class ContentPresenter {

	// MARK: - DI

	var interactor: ContentUnitInteractorProtocol?

	let contentLoader: ContentLoaderProtocol = ContentLoader()

	weak var view: ContentView?

	private(set) var factory: ItemsFactoryProtocol = ItemsFactory()

	private(set) var menuFactory = MenuFactory()

	var settingsProvider: any StateProviderProtocol<Settings>

	var toolbarFactory = ToolbarFactory()

	var router: RouterProtocol

	var localization: UnitLocalizationProtocol = UnitLocalization()

	var editingMode: EditingMode? {
		didSet {
			let selection = view?.selection ?? []
			let model = toolbarFactory.build(
				editingMode: editingMode,
				selectedCount: selection.count,
				isCompleted: cache.validate(.isStrikethrough, other: selection)
			)
			view?.display(model)
			view?.setEditing(editingMode)
		}
	}

	// MARK: - Constants

	private let itemType = "dev.zeroindex.ListAdapter.item"

	private let stringType = UTType.plainText.identifier

	// MARK: - Cache

	var cache = Cache<Property, Item>()

	// MARK: - Initialization

	init(
		router: RouterProtocol,
		settingsProvider: any StateProviderProtocol<Settings> = SettingsProvider.shared
	) {
		self.router = router
		self.settingsProvider = settingsProvider

		settingsProvider.addObservation(for: self) { [weak self] settings in
			self?.interactor?.fetchData()
		}
	}
}

// MARK: - ContentPresenterProtocol
extension ContentPresenter: ContentPresenterProtocol {

	func present(_ content: Content) {
		let nodes = content.root.nodes
		present(nodes)
	}

	func present(_ nodes: [Node<Item>]) {
		var snapshot = Snapshot(nodes)
		snapshot.validate(keyPath: \.isStrikethrough)

		cache.store(.isStrikethrough, keyPath: \.isStrikethrough, equalsTo: true, from: snapshot)

		let converted = snapshot
			.map { info in

					return factory.makeItem(
						item: info.model,
						isLeaf: info.isLeaf,
						iconColor: settingsProvider.state.iconColor
					)
				}
		view?.display(converted)
	}
}

// MARK: - ViewDelegate
extension ContentPresenter: ViewDelegate {

	func viewDidChange(state: ViewState) {
		guard case .didLoad = state else {
			return
		}
		interactor?.fetchData()
		view?.expandAll()

		let toolbar = toolbarFactory.build(
			editingMode: editingMode,
			selectedCount: 0,
			isCompleted: cache.validate(.isStrikethrough, other: view?.selection ?? [])
		)
		view?.display(toolbar)
	}
}

// MARK: - InteractionDelegate
extension ContentPresenter: InteractionDelegate {

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
			let model = DetailsView.Model(
				navigationTitle: localization.editItemNavigationTitle,
				properties: item.details
			)
			router.showDetails(with: model, animateBottomBarItem: ElementIdentifier.new.rawValue) { [weak self] saved, success in
					self?.router.dismiss()
					if success {
						let note = saved.description.isEmpty ? nil : saved.description
						self?.interactor?.set(
							saved.text,
							note: note,
							iconName: saved.icon,
							tintColor: saved.tintColor,
							for: id
						)
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
		case .strikethrough:
			editingMode = nil
			let moveToEnd = settingsProvider.state.completionBehaviour == .moveToEnd
			let newValue = !(cache.validate(.isStrikethrough, other: currentSelection ?? []) ?? false)
			interactor?.setStatus(newValue, for: currentSelection ?? [], moveToEnd: moveToEnd)
		case .select:
			editingMode = .selection
		case .reorder:
			editingMode = .reordering
		case .settings:
			router.showSettings()
		case .done:
			editingMode = nil
		case .expandAll:
			view?.expandAll()
		case .collapseAll:
			view?.collapseAll()
		case .move:
			router.showTargetsScreen(for: Set(currentSelection ?? [])) { [weak self] target, isSuccess in
				self?.router.dismiss()
				guard isSuccess else {
					return
				}
				self?.editingMode = nil
				let destination: Destination<UUID> = if let target {
					.onItem(with: target)
				} else {
					.toRoot
				}
				self?.interactor?.move(ids: currentSelection ?? [], to: destination)
			}
		case .specialReorder:
			guard let first = selection?.first else {
				return
			}
			router.showReorderScreen(for: first) { [weak self] in
				self?.router.dismiss()
			}
		case .icon:
			router.showIconPicker(title: localization.iconPickerNavigationTitle) { [weak self] icon in
				self?.editingMode = nil
				self?.interactor?.setIcon(icon, for: currentSelection ?? [])
			}
		case .color:
			router.showColorPicker(title: localization.colorPickerNavigationTitle) { [weak self] color in
				self?.editingMode = nil
				self?.interactor?.setColor(color, for: currentSelection ?? [])
			}
		}
	}
}

// MARK: - ContentViewDelegate
extension ContentPresenter: ContentViewDelegate { }

// MARK: - ListDelegate
extension ContentPresenter: ListDelegate {

	func listItemHasBeenDelete(id: UUID) {
		interactor?.deleteItems([id])
	}

	func listDidChangeSelection(ids: [UUID]) {
		let toolbar = toolbarFactory.build(
			editingMode: editingMode,
			selectedCount: ids.count,
			isCompleted: cache.validate(.isStrikethrough, other: ids)
		)
		view?.display(toolbar)
	}

	func menu(for ids: [UUID]) -> [MenuElement] {
		menuFactory.build(
			isCompleted: cache.validate(.isStrikethrough, other: ids)
		)
	}
}

import UniformTypeIdentifiers

// MARK: - DropDelegate
extension ContentPresenter: DropDelegate {

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
		return [itemType, stringType]
	}

	func dropItems(providers: [NSItemProvider], to destination: Destination<UUID>) {

		let canLoad = contentLoader.loadItems(providers: providers) { [weak self] nodes in
			self?.interactor?.insertNodes(nodes, to: destination)
		}

		guard !canLoad else {
			return
		}

		_ = contentLoader.loadStrings(providers: providers) { [weak self] strings in
			self?.interactor?.insertStrings(strings, to: destination)
		}
	}

	func provider(for id: UUID) -> NSItemProvider? {

		let provider = NSItemProvider()

		if let text = interactor?.string(for: [id]) {
			provider.registerObject(text as NSString, visibility: .all)
		}

		provider.registerDataRepresentation(forTypeIdentifier: itemType, visibility: .ownProcess) { [weak self] handler in
			guard let data = self?.interactor?.data(of: id) else {
				handler(nil, nil)
				return nil
			}
			handler(data, nil)
			return nil
		}

		return provider
	}
}

// MARK: - Helpers
private extension ContentPresenter {

	func createNew(target: UUID?) {
		let model = DetailsView.Model(navigationTitle: localization.newItemNavigationTitle, properties: .init(text: ""))
		router.showDetails(with: model, animateBottomBarItem: ElementIdentifier.new.rawValue) { [weak self] saved, success in
			self?.router.dismiss()
			if success {
				let note = saved.description.isEmpty ? nil : saved.description

				guard let id = self?.interactor?.newItem(
					saved.text,
					note: note,
					iconName: saved.icon,
					tintColor: saved.tintColor,
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
}

private extension Item {

	var details: DetailsView.Properties {
        return .init(
            text: text,
            description: note ?? "",
            icon: iconName,
            tintColor: tintColor
        )
	}
}

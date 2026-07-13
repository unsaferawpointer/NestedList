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
import CorePresentation

@MainActor
protocol ContentPresenterProtocol: AnyObject {
	func present(snapshot: Snapshot<Item>)
	func presentRoot(item: Item)
}

@MainActor
final class ContentPresenter {

	// MARK: - DI

	var interactor: ContentUnitInteractorProtocol?

	let contentLoader: ContentLoaderProtocol = ContentLoader()

	weak var view: ContentView?

	private(set) var factory: ItemsFactoryProtocol = ItemsFactory()

	var settingsProvider: any StateProviderProtocol<Settings>

	var router: ContentRouterProtocol

	var localization: UnitLocalizationProtocol = UnitLocalization()

	private(set) var soundPlayer: any SoundPlayerProtocol

	private(set) var analytics: any ContentAnalyticsServiceProtocol

	var editingMode: EditingMode? {
		didSet {
			displayToolbar()
			view?.setEditing(editingMode)
		}
	}

	// MARK: - Cache

	var cache = Cache<Property, Item>()

	// MARK: - Initialization

	init(
		router: ContentRouterProtocol,
		settingsProvider: any StateProviderProtocol<Settings> = SettingsProvider.shared,
		analytics: any ContentAnalyticsServiceProtocol = ContentAnalyticsService(),
		soundPlayer: any SoundPlayerProtocol
	) {
		self.router = router
		self.settingsProvider = settingsProvider
		self.analytics = analytics
		self.soundPlayer = soundPlayer

		settingsProvider.addObservation(for: self) { [weak self] settings in
			guard let interactor = self?.interactor else {
				return
			}
			let (item, snapshot) = interactor.fetchData()
			self?.present(snapshot: snapshot)
			if let item {
				self?.presentRoot(item: item)
			}
		}
	}
}

// MARK: - ContentPresenterProtocol
extension ContentPresenter: ContentPresenterProtocol {

	func present(snapshot: Snapshot<Item>) {
		var pruned = snapshot.pruned { item in
			item.isSubitemsHidden
		}
		pruned.validate(keyPath: \.isStrikethrough)

		cache.store(.isStrikethrough, keyPath: \.isStrikethrough, equalsTo: true, from: pruned)
		cache.store(.isSubitemsHidden, keyPath: \.isSubitemsHidden, equalsTo: true, from: pruned)

		let converted = pruned
			.map { info in
				return factory.makeItem(
					item: info.model,
					isLeaf: info.isLeaf,
					iconColor: settingsProvider.state.iconColor
				)
			}
		view?.display(converted)
	}

	func presentRoot(item: Item) {
		view?.display(title: item.text)
	}
}

// MARK: - ViewDelegate
extension ContentPresenter: ViewDelegate {

	func viewDidChange(state: ViewState) {
		guard let interactor else {
			return
		}
		switch state {
		case .didLoad:
			let (item, snapshot) = interactor.fetchData()
			present(snapshot: snapshot)
			if let item {
				presentRoot(item: item)
			}
			view?.expandAll()
			displayToolbar()

			// MARK: - Analytics
			Task {
				let event: ContentAnalyticsEvent = .documentShow(
					depth: snapshot.depth,
					totalCount: snapshot.count,
					isRoot: item == nil
				)
				await analytics.track(event)
			}
		case .willAppear:
			displayToolbar()
		default:
			return
		}
	}
}

// MARK: - Helpers
private extension ContentPresenter {

	func paste(selection: [UUID]) {
		editingMode = nil
		guard let string = UIPasteboard.general.string, let target = selection.first else {
			return
		}
		interactor?.insertStrings([string], to: .onItem(with: target))
	}

	func newItem(selection: [UUID]) {
		editingMode = nil
		createNew(target: selection.first)
	}

	func cut(selection: [UUID]) {
		editingMode = nil
		guard let interactor else {
			return
		}
		let string = interactor.string(for: selection)
		UIPasteboard.general.string = string
		interactor.deleteItems(selection)
	}

	func copy(selection: [UUID]) {
		editingMode = nil
		guard let interactor else {
			return
		}
		let string = interactor.string(for: selection)
		UIPasteboard.general.string = string
	}

	func delete(selection: [UUID]) {
		editingMode = nil
		interactor?.deleteItems(selection)
	}

	func edit(selection: [UUID]) {
		editingMode = nil
		guard let id = selection.first, let item = interactor?.item(for: id) else {
			return
		}
		let model = ItemDetailsView.Model(
			navigationTitle: localization.editItemNavigationTitle,
			properties: item.details
		)
		router.showDetails(with: model, animateBottomBarItem: ContentToolbarIdentifier.newItem.rawValue) { [weak self] saved, success in
			self?.router.dismiss()
			if success {
				let note = saved.description.isEmpty ? nil : saved.description
				self?.interactor?.set(
					saved.text,
					note: note,
					for: id
				)
			}
		}
	}

	func move(selection: [UUID]) {
		router.showTargetsScreen(for: Set(selection)) { [weak self] target, isSuccess in
			self?.router.dismiss()
			guard isSuccess else {
				return
			}
			self?.editingMode = nil
			self?.soundPlayer.play(sound: .place)
			self?.interactor?.move(ids: selection, to: target)
		}
	}

	func showIconPicker(selection: [UUID]) {
		router.showIconPicker(title: localization.iconPickerNavigationTitle) { [weak self] icon in
			self?.editingMode = nil
			self?.interactor?.setIcon(icon, for: selection)
		}
	}

	func showColorPicker(selection: [UUID]) {
		router.showColorPicker(title: localization.colorPickerNavigationTitle) { [weak self] color in
			self?.editingMode = nil
			self?.interactor?.setColor(color, for: selection)
		}
	}

	func showReorderScreen(selection: [UUID]) {
		guard let first = selection.first else {
			return
		}
		router.showReorderScreen(for: first) { [weak self] in
			self?.router.dismiss()
		}
	}

	func toggleHideSubitemsFlag(selection: [UUID]) {
		editingMode = nil
		let newValue = !(cache.validate(.isSubitemsHidden, other: selection) ?? false)
		interactor?.setSubitemsHidden(newValue, for: selection)
	}

	func toggleStrikethroughFlag(selection: [UUID]) {
		editingMode = nil
		let moveToEnd = settingsProvider.state.completionBehaviour == .moveToEnd
		let newValue = !(cache.validate(.isStrikethrough, other: selection) ?? false)
		soundPlayer.play(sound: newValue ? .mark : .unmark)
		interactor?.setStatus(newValue, for: selection, moveToEnd: moveToEnd)
	}
}

// MARK: - ContentMenuDelegate
extension ContentPresenter: ContentMenuDelegate {

	func userDidTapMenu(with id: ContentMenuIdentifier, selection: [UUID]?) {
		let currentSelection = selection ?? view?.selection ?? []

		// MARK: - Analytics
		let event: ContentAnalyticsEvent = .menuClick(id: id.rawValue, source: .context)
		Task { await analytics.track(event) }

		switch id {
		case .cutItems:						cut(selection: currentSelection)
		case .copyItems:					copy(selection: currentSelection)
		case .paste:						paste(selection: currentSelection)
		case .editItem:						edit(selection: currentSelection)
		case .newItem:						newItem(selection: currentSelection)
		case .toggleStrikethrough:			toggleStrikethroughFlag(selection: currentSelection)
		case .toggleSubitemsVisibility:		toggleHideSubitemsFlag(selection: currentSelection)
		case .changeIcon:					showIconPicker(selection: currentSelection)
		case .changeColor:					showColorPicker(selection: currentSelection)
		case .moveItems:					move(selection: currentSelection)
		case .reorderItems:					showReorderScreen(selection: currentSelection)
		case .deleteItems:					delete(selection: currentSelection)
		}
	}
}

// MARK: - ContentToolbarDelegate
extension ContentPresenter: ContentToolbarDelegate {

	func userDidTapToolbar(with id: ContentToolbarIdentifier, selection: [UUID]?) {
		let currentSelection = selection ?? view?.selection ?? []

		// MARK: - Analytics
		let event: ContentAnalyticsEvent = .buttonClick(id: id.rawValue, source: "toolbar")
		Task { await analytics.track(event) }

		switch id {
		case .cutItems:						cut(selection: currentSelection)
		case .copyItems:					copy(selection: currentSelection)
		case .newItem:						newItem(selection: currentSelection)
		case .toggleStrikethrough:			toggleStrikethroughFlag(selection: currentSelection)
		case .toggleSubitemsVisibility:		toggleHideSubitemsFlag(selection: currentSelection)
		case .changeIcon:					showIconPicker(selection: currentSelection)
		case .changeColor:					showColorPicker(selection: currentSelection)
		case .moveItems:					move(selection: currentSelection)
		case .deleteItems:					delete(selection: currentSelection)
		case .done:							editingMode = nil
		case .settings:						router.showSettings()
		case .reorderingMode:				editingMode = .reordering
		case .selectionMode:				editingMode = .selection
		case .selectAll:					view?.selectAll()
		case .collapseAll:					view?.collapseAll()
		case .expandAll:					view?.expandAll()
		case .more:							break
		}
	}
}

// MARK: - ContentViewDelegate
extension ContentPresenter: ContentViewDelegate {

	func menuConfiguration(for ids: [UUID]) -> ContentMenuConfiguration {
		var state: [String: Bool] = [:]
		if let result = cache.validate(.isStrikethrough, other: ids) {
			state[ContentMenuIdentifier.toggleStrikethrough.rawValue] = result
		}
		if let result = cache.validate(.isSubitemsHidden, other: ids) {
			state[ContentMenuIdentifier.toggleSubitemsVisibility.rawValue] = result
		}
		return ContentMenuConfiguration(state: state)
	}
}

// MARK: - ListDelegate
extension ContentPresenter: ListDelegate {

	func listItemHasBeenDelete(id: UUID) {
		interactor?.deleteItems([id])
	}

	func listDidChangeSelection(ids: [UUID]) {
		displayToolbar(selection: ids)
	}

	func listDidTapDisclosure(id: UUID) {
		// MARK: - Analytics
		Task {
			let event: ContentAnalyticsEvent = .subitemsShow
			await analytics.track(event)
		}

		router.showDocument(for: id)
	}
}

// MARK: - DropDelegate
extension ContentPresenter: DropDelegate {

	typealias ID = UUID

	func move(_ ids: [UUID], to destination: Destination<UUID>) {
		// MARK: - Analytics
		let event: ContentAnalyticsEvent = .dragDropMove(itemsCount: ids.count)
		Task { await analytics.track(event) }

		soundPlayer.play(sound: .place)
		interactor?.move(ids: ids, to: destination)
		if let target = destination.id {
			view?.expand(target)
		}
	}
	
	func validateMovement(_ ids: [UUID], to destination: Destination<UUID>) -> Bool {
		interactor?.validateMovement(ids, to: destination) ?? false
	}

	func availableTypes() -> [String] {
		return contentLoader.availableTypes()
	}

	func dropItems(providers: [NSItemProvider], to destination: Destination<UUID>) {

		let canLoad = contentLoader.loadItems(providers: providers) { [weak self] nodes in
			// MARK: - Analytics
			let event: ContentAnalyticsEvent = .dragDropInsert(itemsCount: nodes.count, contentType: "item")
			Task { await self?.analytics.track(event) }

			self?.interactor?.insertNodes(nodes, to: destination)
		}

		guard !canLoad else {
			return
		}

		_ = contentLoader.loadStrings(providers: providers) { [weak self] strings in
			// MARK: - Analytics
			let event: ContentAnalyticsEvent = .dragDropInsert(itemsCount: strings.count, contentType: "string")
			Task { await self?.analytics.track(event) }

			self?.interactor?.insertStrings(strings, to: destination)
		}
	}

	func provider(for id: UUID) -> NSItemProvider? {
		let text = interactor?.string(for: [id])
		let data = interactor?.data(of: id)
		return contentLoader.itemProvider(text: text, data: data)
	}
}

// MARK: - Helpers
private extension ContentPresenter {

	@MainActor func createNew(target: UUID?) {
		let model = ItemDetailsView.Model(navigationTitle: localization.newItemNavigationTitle, properties: .init(text: ""))
		router.showDetails(with: model, animateBottomBarItem: ContentToolbarIdentifier.newItem.rawValue) { [weak self] saved, success in
			self?.router.dismiss()
			if success {
				let note = saved.description.isEmpty ? nil : saved.description
				guard let id = self?.interactor?.newItem(with: .init(text: saved.text, note: note), target: target) else {
					return
				}
				if let target {
					self?.view?.expand(target)
				}
				self?.view?.scroll(to: id)
			}
		}
	}

	func displayToolbar(selection: [UUID]? = nil) {
		let selection = selection ?? view?.selection ?? []
		let configuration = ContentToolbarConfiguration(
			editingMode: editingMode,
			selection: selection,
			isCompleted: cache.validate(.isStrikethrough, other: selection),
			isSubitemsHidden: cache.validate(.isSubitemsHidden, other: selection)
		)
		view?.apply(configuration)
	}
}

enum Property: Hashable {
	case isStrikethrough
	case isSubitemsHidden
}

private extension Item {

	var details: ItemDetailsView.Properties {
        return .init(
            text: text,
            description: note ?? ""
        )
	}
}

//
//  ContentPresenter.swift
//  macOS
//
//  Created by Anton Cherkasov on 16.11.2024.
//

import Foundation
import AppKit

import CoreModule
import DesignSystem
import Hierarchy
import CorePresentation

@MainActor
protocol ContentPresenterProtocol: AnyObject {
	func present(_ snapshot: Snapshot<Item>)
	func presentRoot(item: Item)
	func close()
}

@MainActor
final class ContentPresenter {

	// MARK: DI by initialization

	private var router: any ContentRouterProtocol

	// MARK: - DI

	var interactor: ContentInteractorProtocol?

	weak var view: UnitView?

	private(set) var factory: ItemsFactoryProtocol = ItemsFactory()

	private(set) var localization: ContentLocalizationProtocol

	private(set) var settingsProvider: any StateProviderProtocol<Settings>

	private(set) var analytics: any ContentAnalyticsServiceProtocol

	private(set) var soundPlayer: any SoundPlayerProtocol

	// MARK: - Constants

	private let stringType = NSPasteboard.PasteboardType.string.rawValue

	private let itemType = "dev.zeroindex.ListAdapter.item"

	// MARK: - Cache

	private(set) var cache = Cache<Property, Item>()

	init(
		router: any ContentRouterProtocol,
		settingsProvider: any StateProviderProtocol<Settings> = SettingsProvider.shared,
		localization: ContentLocalizationProtocol = ContentLocalization(),
		analytics: any ContentAnalyticsServiceProtocol = ContentAnalyticsService(),
		soundPlayer: any SoundPlayerProtocol
	) {
		self.router = router
		self.settingsProvider = settingsProvider
		self.localization = localization
		self.analytics = analytics
		self.soundPlayer = soundPlayer

		settingsProvider.addObservation(for: self) { [weak self] settings in
			guard let interactor = self?.interactor else {
				return
			}
			let (item, snapshot) = interactor.fetchData()
			self?.present(snapshot)
			if let item {
				self?.presentRoot(item: item)
			}
		}
	}

	deinit {
			settingsProvider.removeObserver(self)
	}
}

// MARK: - ContentPresenterProtocol
extension ContentPresenter: ContentPresenterProtocol {

	func present(_ originalSnapshot: Snapshot<Item>) {
		var snapshot = originalSnapshot.pruned {
			$0.isSubitemsHidden
		}
		snapshot.validate(keyPath: \.isStrikethrough)

		// MARK: - Cache
		cache.store(.isStrikethrough, keyPath: \.isStrikethrough, equalsTo: true, from: snapshot)
		cache.store(.isSubitemsHidden, keyPath: \.isSubitemsHidden, equalsTo: true, from: snapshot)
		cache.store(.hasNote, keyPath: \.note, notEqualsTo: nil, from: snapshot)

		let converted = snapshot.map { info in
			factory.makeItem(
				item: info.model,
				isLeaf: info.isLeaf,
				iconColor: settingsProvider.state.iconColor
			)
		}

		guard !converted.identifiers.isEmpty else {
			let placeholderModel: PlaceholderModel = .init(
				icon: "plus.square.on.square",
				title: localization.placeholderTitle,
				subtitle: localization.placeholderDescription
			)
			view?.display(.placeholder(model: placeholderModel))
			return
		}

		view?.display(.list(snapshot: converted))
	}

	func presentRoot(item: Item) {
		view?.updateTitle(item.text)
	}

	func close() {
		view?.close()
	}
}

// MARK: - ListDelegate
extension ContentPresenter: ListDelegate {

	func handleDoubleClick(on item: UUID) {
		// MARK: - Analytics
		let event: ContentAnalyticsEvent = .itemDoubleClick
		Task { await analytics.track(event) }

		let isValid = cache.validate(.isStrikethrough, other: [item])
		if isValid == true {
			soundPlayer.play(sound: .unmark)
		} else {
			soundPlayer.play(sound: .mark)
		}
		let completionBehaviour = settingsProvider.state.completionBehaviour
		let moveToEnd = completionBehaviour == .moveToEnd

		interactor?.toggleStrikethrough(for: item, moveToEnd: moveToEnd)
	}
}

// MARK: - ViewDelegate
extension ContentPresenter: ViewDelegate {

	func viewDidChange(state: ViewState) {
		guard case .didLoad = state, let interactor else {
			return
		}
		let (item, snapshot) = interactor.fetchData()
		present(snapshot)
		if let item {
			presentRoot(item: item)
		}
		view?.expand(nil)

		// MARK: - Analytics
		Task {
			let event: ContentAnalyticsEvent = .documentShow(
				depth: snapshot.depth,
				totalCount: snapshot.count,
				isRoot: item == nil
			)
			await analytics.track(event)
		}
	}
}

// MARK: - UnitViewOutput
extension ContentPresenter: UnitViewOutput {

	func menuItems() -> [ContentMenuIdentifier] {
		return [.newItem,
				.separator,
				.editItem,
				.separator,
				.toggleStrikethrough,
				.toggleSubitemsVisibility,
				.separator,
				.toggleNote,
				.separator,
				.appearanceHeader,
				.changeIcon, .changeColor,
				.separator,
				.deleteItems]
	}

	func toolbarButtonClicked(id: ElementIdentifier) {
		guard id.rawValue == "new-item-toolbar-item" else {
			return
		}
		guard let selection = view?.selection else {
			return
		}

		// MARK: - Analytics
		let event: ContentAnalyticsEvent = .buttonClick(id: "new-item", source: "toolbar")
		Task { await analytics.track(event) }

		newItem(in: selection)
	}

	func menuItemClicked(_ item: ContentMenuIdentifier, source: MenuSource = .context) {
		guard let selection = view?.selection else {
			return
		}

		// MARK: - Analytics
		let event: ContentAnalyticsEvent = .menuClick(id: item.rawValue, source: source)
		Task { await analytics.track(event) }

		switch item {
		case .newItem:
			newItem(in: selection)
		case .toggleStrikethrough:
			toggleStrikethrough(for: selection)
		case .toggleSubitemsVisibility:
			toggleSubitemsHidden(for: selection)
		case .toggleNote:
			toggleNote(for: selection)
		case .editItem:
			editItem(with: selection)
		case .deleteItems:
			delete(ids: selection)
		case .cutItems:
			cut(ids: selection)
		case .copyItems:
			copy(ids: selection)
		case .paste:
			paste(ids: selection)
		case .changeColor:
			showColorPicker(for: selection)
		case .changeIcon:
			showIconPicker(for: selection)
		case .appearanceHeader, .separator:
			assertionFailure("Unexpected menu item identifier")
		}
	}
	
	func validateMenuItem(_ item: ContentMenuIdentifier) -> Bool {
		switch item {
		case .newItem:
			return true
		case .paste:
			let types = Set([stringType, itemType])
			let pasteboard = Pasteboard(pasteboard: NSPasteboard.general)
			return pasteboard.contains(types)
		case .appearanceHeader, .separator:
			return false
		default:
			return view?.selection.isEmpty == false
		}
	}
	
	func stateForMenuItem(_ item: ContentMenuIdentifier) -> ControlState {
		guard let selection = view?.selection else {
			return .off
		}
		return switch item {
		case .toggleStrikethrough:
			cache.validate(.isStrikethrough, other: selection).state
		case .toggleSubitemsVisibility:
			cache.validate(.isSubitemsHidden, other: selection).state
		case .toggleNote:
			cache.validate(.hasNote, other: selection).state
		default:
			.off
		}
	}
}

// MARK: - Helpers
private extension ContentPresenter {

	func newItem(in selection: [UUID]) {

		let target = selection.first
		let properties = ItemProperties(text: localization.newItemText)

		guard let id = interactor?.newItem(with: properties, target: target) else {
			return
		}

		if let target {
			view?.expand([target])
		}
		view?.scroll(to: id)
		view?.focus(on: id, key: "title")
	}

	func editItem(with selection: [UUID]) {
		guard let id = selection.first, let item = interactor?.nodes(for: [id]).first?.value else {
			return
		}
		let model = ItemDetailsView.Model(
			navigationTitle: localization.editItemDetailsTitle,
			properties: item.details
		)
		router.showDetails(with: model) { [weak self] saved in
			let note = saved.description.isEmpty ? nil : saved.description
			self?.interactor?.set(text: saved.text, note: note, for: id)
		}
	}

	func showIconPicker(for ids: [UUID]) {
		router.showIconPicker(navigationTitle: localization.iconPickerNavigationTitle) { [weak self] iconName in
			self?.interactor?.setIcon(iconName, for: ids)
		}
	}

	func showColorPicker(for ids: [UUID]) {
		router.showColorPicker(navigationTitle: localization.colorPickerNavigationTitle) { [weak self] color in
			self?.interactor?.setColor(color, for: ids)
		}
	}

	func toggleStrikethrough(for ids: [UUID]) {
		let completionBehaviour = settingsProvider.state.completionBehaviour
		let moveToEnd = completionBehaviour == .moveToEnd
		let status = cache.validate(.isStrikethrough, other: ids) ?? false
		interactor?.setStatus(!status, for: ids, moveToEnd: moveToEnd)
	}

	func toggleNote(for ids: [UUID]) {
		let hasNote = cache.validate(.hasNote, other: ids) ?? false
		interactor?.set(note: !hasNote ? localization.newNoteText : nil, for: ids)
		if !hasNote, let first = ids.first {
			view?.focus(on: first, key: "subtitle")
		}
	}

	func toggleSubitemsHidden(for ids: [UUID]) {
		let isSubitemsHidden = cache.validate(.isSubitemsHidden, other: ids) ?? false
		interactor?.setSubitemsHidden(!isSubitemsHidden, for: ids)
	}

	func delete(ids: [UUID]) {
		interactor?.deleteItems(ids)
	}
}

// MARK: - Support Pasteboard
private extension ContentPresenter {

	func cut(ids: [UUID]) {
		guard
			let selection = view?.selection, let interactor, !selection.isEmpty,
			let info = pasteboardInfo(for: selection)
		else {
			return
		}

		let pasteboard = Pasteboard(pasteboard: NSPasteboard.general)
		pasteboard.setInfo(info, clearContents: true)
		interactor.deleteItems(selection)
	}

	func copy(ids: [UUID]) {
		guard let selection = view?.selection, !selection.isEmpty else {
			return
		}

		guard let info = pasteboardInfo(for: selection) else {
			return
		}

		let pasteboard = Pasteboard(pasteboard: .general)
		pasteboard.setInfo(info, clearContents: true)
	}

	func paste(ids: [UUID]) {
		let pasteboard = Pasteboard(pasteboard: NSPasteboard.general)

		guard
			let info = pasteboard.getInfo()
		else {
			return
		}

		let destination: Destination<UUID> = if let first = view?.selection.first {
			.onItem(with: first)
		} else {
			.toRoot
		}

		if info.containsInfo(of: itemType) {
			let data = info.items.compactMap { item in
				item.data[itemType]
			}
			interactor?.insertItems(data, to: destination)
		} else {
			let data = info.items.compactMap { item in
				item.data[stringType]
			}
			interactor?.insertStrings(data, to: destination)
		}
	}
}

// MARK: - DropDelelgate
extension ContentPresenter: DropDelegate {
	
	typealias ID = UUID
	
	func move(_ ids: [UUID], to destination: Destination<UUID>) {
		// MARK: - Analytics
		let event: ContentAnalyticsEvent = .dragDropMove(itemsCount: ids.count)
		Task { await analytics.track(event) }

		soundPlayer.play(sound: .place)
		interactor?.move(ids, to: destination)
	}
	
	func copy(_ ids: [UUID], to destination: Destination<UUID>) {
		// MARK: - Analytics
		let event: ContentAnalyticsEvent = .dragDropCopy(itemsCount: ids.count)
		Task { await analytics.track(event) }

		interactor?.copy(ids, to: destination)
	}
	
	func validateMovement(_ ids: [UUID], to destination: Destination<UUID>) -> Bool {
		interactor?.validateMovement(ids, to: destination) ?? false
	}
	
	func validateDrop(_ info: PasteboardInfo, to destination: Destination<UUID>) -> Bool {
		info.containsInfo(of: stringType) || info.containsInfo(of: itemType)
	}

	func drop(_ info: PasteboardInfo, to destination: Destination<UUID>) {
		if info.containsInfo(of: itemType) {
			let data = info.items.compactMap { item in
				item.data[itemType]
			}

			// MARK: - Analytics
			let event: ContentAnalyticsEvent = .dragDropInsert(itemsCount: data.count, contentType: "item")
			Task { await analytics.track(event) }

			interactor?.insertItems(data, to: destination)
		} else {
			let data = info.items.compactMap { item in
				item.data[stringType]
			}

			// MARK: - Analytics
			let event: ContentAnalyticsEvent = .dragDropInsert(itemsCount: data.count, contentType: "string")
			Task { await analytics.track(event) }

			interactor?.insertStrings(data, to: destination)
		}
	}

	func availableTypes() -> Set<String> {
		return [itemType, stringType]
	}
}

// MARK: - DragDelegate
extension ContentPresenter: DragDelegate {

	func write(ids: [UUID], to pasteboard: any PasteboardProtocol) {
		guard let info = pasteboardInfo(for: ids) else {
			return
		}

		pasteboard.setInfo(info, clearContents: false)
	}

}

// MARK: - CellDelegate
extension ContentPresenter: CellDelegate {

	typealias Model = ItemModel

	func cellDidChange(newValue: ItemModel.Value, id: UUID) {
		guard !newValue.title.isEmpty else {
			interactor?.deleteItems([id])
			return
		}
		let note: String? = if let subtitle = newValue.subtitle {
			subtitle.isEmpty ? nil : subtitle
		} else {
			nil
		}
		interactor?.set(text: newValue.title, note: note, for: id)
	}

	func cellDidTapDisclosure(id: UUID) {
		// MARK: - Analytics
		Task {
			let event: ContentAnalyticsEvent = .subitemsShow
			await analytics.track(event)
		}
		router.showDocument(for: id)
	}
}

// MARK: - Helpers
private extension ContentPresenter {

	func pasteboardInfo(for ids: [UUID]) -> PasteboardInfo? {
		guard let nodes = interactor?.nodes(for: ids) else {
			return nil
		}

		let parser = Parser()

		let items = nodes.map {
			PasteboardInfo.Item(
				data:
					[
						itemType : interactor?.data(for: $0.id) ?? Data(),
						stringType: parser.format($0).data(using: .utf8) ?? Data()
					]
			)
		}

		return PasteboardInfo(items: items)
	}

	func validateStatus() -> Bool? {
		guard let selection = view?.selection, !selection.isEmpty else {
			return false
		}
		return cache.validate(.isStrikethrough, other: selection)
	}
}

enum Property: Hashable {
	case isStrikethrough
	case isSubitemsHidden
	case hasNote
}

extension Optional<Bool> {

	var state: ControlState {
		switch self {
		case .none:					.mixed
		case .some(let wrapped):	wrapped ? .on : .off
		}
	}
}

private extension Item {

	var details: ItemDetailsView.Properties {
		return .init(text: text, description: note ?? "")
	}
}

extension ItemStyle {

	var icon: ItemIcon? {
		switch self {
		case .item:
			return nil
		case .section(let icon):
			return icon
		}
	}

	var semanticImage: SemanticImage? {
		switch self {
		case .item:
			return .point
		case let .section(icon):
			return IconMapper.map(icon: icon?.name, filled: false)
		}
	}
}

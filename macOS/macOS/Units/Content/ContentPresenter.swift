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
import CoreSettings
import CorePresentation

@MainActor
protocol ContentPresenterProtocol: AnyObject {
	func present(_ content: Content)
	func present(_ nodes: [Node<Item>])
}

@MainActor
final class ContentPresenter {

	// MARK: DI by initialization

	private var router: any RouterProtocol

	// MARK: - DI

	var interactor: ContentInteractorProtocol?

	weak var view: UnitView?

	private(set) var factory: ItemsFactoryProtocol = ItemsFactory()

	private(set) var localization: ContentLocalizationProtocol

	private(set) var settingsProvider: any StateProviderProtocol<Settings>

	// MARK: - Constants

	private let stringType = NSPasteboard.PasteboardType.string.rawValue

	private let itemType = "dev.zeroindex.ListAdapter.item"

	// MARK: - Cache

	private(set) var cache = Cache<Property, Item>()

	init(
		router: any RouterProtocol,
		settingsProvider: any StateProviderProtocol<Settings> = SettingsProvider.shared,
		localization: ContentLocalizationProtocol = ContentLocalization()
	) {
		self.router = router
		self.settingsProvider = settingsProvider
		self.localization = localization

		settingsProvider.addObservation(for: self) { [weak self] settings in
			self?.interactor?.fetchData()
		}
	}

	deinit {
		settingsProvider.removeObserver(self)
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

		// MARK: - Cache
		cache.store(.isStrikethrough, keyPath: \.isStrikethrough, equalsTo: true, from: snapshot)
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
}

// MARK: - ListDelegate
extension ContentPresenter: ListDelegate {

	func handleDoubleClick(on item: UUID) {
		let completionBehaviour = settingsProvider.state.completionBehaviour
		let moveToEnd = completionBehaviour == .moveToEnd
		interactor?.toggleStrikethrough(for: item, moveToEnd: moveToEnd)
	}
}

// MARK: - ViewDelegate
extension ContentPresenter: ViewDelegate {

	func viewDidChange(state: ViewState) {
		guard case .didLoad = state else {
			return
		}
		interactor?.fetchData()
		view?.expand(nil)
	}
}

// MARK: - UnitViewOutput
extension ContentPresenter: UnitViewOutput {

	func configure(for root: UUID?) {
		interactor?.configure(for: root)
	}

	func menuItems() -> [ElementIdentifier] {
		return [.newItem,
				.separator,
				.edit,
				.separator,
				.completed,
				.separator,
				.note,
				.separator,
				.appearanceHeader,
				.icon, .color,
				.separator,
				.delete]
	}

	func menuItemClicked(_ item: ElementIdentifier) {
		guard let selection = view?.selection else {
			return
		}

		switch item {
		case .newItem:		newItem(in: selection)
		case .completed:	toggleStrikethrough(for: selection)
		case .note:			toggleNote(for: selection)
		case .edit:			editItem(with: selection)
		case .delete:		delete(ids: selection)
		case .cut:			cut(ids: selection)
		case .copy:			copy(ids: selection)
		case .paste:		paste(ids: selection)
		case .noColor:		interactor?.setColor(nil, for: selection)
		case .icon:			showIconPicker(for: selection)
		default:
			let components = item.rawValue.split(separator: "-")
			guard components.count == 2, let last = components.last,
				  let index = Int(last), let key = components.first else {
				return
			}

			switch key {
			case "color":
				interactor?.setColor(.init(rawValue: index) ?? .tertiary, for: selection)
			default:
				fatalError()
			}
		}
	}
	
	func validateMenuItem(_ item: ElementIdentifier) -> Bool {
		switch item {
		case .newItem:
			return true
		case .paste:
			let types = Set([stringType, itemType])
			let pasteboard = Pasteboard(pasteboard: NSPasteboard.general)
			return pasteboard.contains(types)
		default:

			let components = item.rawValue.split(separator: "-")
			guard
				components.count == 2, let last = components.last, Int(last) != nil, let key = components.first
			else {
				return view?.selection.isEmpty == false
			}

			switch key {
			case "color":
				guard let selection = view?.selection else {
					return false
				}
				return true
			default:
				return view?.selection.isEmpty != false
			}
		}
	}
	
	func stateForMenuItem(_ item: ElementIdentifier) -> ControlState {
		guard let selection = view?.selection else {
			return .off
		}
		return switch item {
		case .completed:
			cache.validate(.isStrikethrough, other: selection).state
		case .note:
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

		guard let id = interactor?.newItem(
			localization.newItemText,
			isStrikethrough: false,
			note: nil,
			iconName: nil,
			tintColor: nil,
			target: target
		) else {
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
			self?.interactor?.set(
				saved.text,
				note: note,
				iconName: saved.icon,
				tintColor: saved.tintColor,
				for: id
			)
		}
	}

	func showIconPicker(for ids: [UUID]) {
		router.showIconPicker(navigationTitle: localization.iconPickerNavigationTitle) { [weak self] iconName in
			self?.interactor?.setIcon(iconName, for: ids)
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
		interactor?.move(ids, to: destination)
	}
	
	func copy(_ ids: [UUID], to destination: Destination<UUID>) {
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
			interactor?.insertItems(data, to: destination)
		} else {
			let data = info.items.compactMap { item in
				item.data[stringType]
			}
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
}

// MARK: - Helpers
private extension ContentPresenter {

	func pasteboardInfo(for ids: [UUID]) -> PasteboardInfo? {
		guard let nodes = interactor?.nodes(for: ids) else {
			return nil
		}

		let encoder = JSONEncoder()
		let parser = Parser()

		let items = nodes.map {
			PasteboardInfo.Item(
				data:
					[
						itemType : (try? encoder.encode($0)) ?? Data(),
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
		return .init(
			text: text,
			description: note ?? "",
			icon: iconName,
			tintColor: tintColor
		)
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

//
//  ContentPresenter.swift
//  macOS
//
//  Created by Anton Cherkasov on 16.11.2024.
//

import Foundation

import CoreModule
import DesignSystem
import Hierarchy
import CoreSettings

import AppKit

protocol ContentPresenterProtocol: AnyObject {
	func present(_ content: Content)
	func present(_ nodes: [Node<Item>])
}

final class ContentPresenter {

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
		settingsProvider: any StateProviderProtocol<Settings> = SettingsProvider.shared,
		localization: ContentLocalizationProtocol = ContentLocalization()
	) {
		self.settingsProvider = settingsProvider
		self.localization = localization

		settingsProvider.addObservation(for: self) { [weak self] _, settings in
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
		snapshot.validate(keyPath: \.isMarked)

		cache.store(.isStrikethrough, keyPath: \.isStrikethrough, equalsTo: true, from: snapshot)
		cache.store(.isMarked, keyPath: \.isMarked, equalsTo: true, from: snapshot)
		cache.store(property: .isSection, from: snapshot) { item in
			guard case .section = item.style else {
				return false
			}
			return true
		}
		cache.store(.hasNote, keyPath: \.note, notEqualsTo: nil, from: snapshot)

		let converted = snapshot.map { info in
			factory.makeItem(
				item: info.model,
				level: info.level,
				iconColor: settingsProvider.state.iconColor
			)
		}

		guard !converted.identifiers.isEmpty else {
			let placeholderModel: PlaceholderModel = .init(
				icon: "shippingbox",
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

	func menuItems() -> [ElementIdentifier] {
		return [.newItem,
				.separator,
				.edit,
				.separator,
				.completed, .marked, .section,
				.separator,
				.note,
				.separator,
				.icon, .color,
				.separator,
				.delete]
	}

	func isHidden(_ item: ElementIdentifier) -> Bool {
		guard item != .paste else {
			let types = Set([stringType, itemType])
			let pasteboard = Pasteboard(pasteboard: NSPasteboard.general)
			return !pasteboard.contains(types)
		}

		guard let selection = view?.selection else {
			return false
		}

		if selection.isEmpty {
			return item != .newItem
		} else {
			if item == .color || item == .icon {
				return cache.validate(.isSection, other: selection) == false
			}
			return false
		}
	}

	func menuItemClicked(_ item: ElementIdentifier) {
		guard let selection = view?.selection else {
			return
		}

		switch item {
		case .newItem:		newItem(in: selection)
		case .completed:	toggleStrikethrough(for: selection)
		case .marked:		toggleMark(for: selection)
		case .note:			toggleNote(for: selection)
		case .edit:			editItem(with: selection)
		case .delete:		delete(ids: selection)
		case .cut:			cut(ids: selection)
		case .copy:			copy(ids: selection)
		case .paste:		paste(ids: selection)
		case .section:		toggleStyle(for: selection)
		case .noIcon:		interactor?.setIcon(nil, for: selection)
		default:
			let components = item.rawValue.split(separator: "-")
			guard
				components.count == 2, let last = components.last, let index = Int(last), let key = components.first
			else {
				assertionFailure("Undefined menu item: \(item)")
				return
			}

			switch key {
			case "icon":
				interactor?.setIcon(.init(rawValue: index) ?? .document, for: selection)
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
		case .noIcon:
			guard let selection = view?.selection, cache.validate(.isSection, other: selection) != false else {
				return false
			}
			return true
		default:

			let components = item.rawValue.split(separator: "-")
			guard
				components.count == 2, let last = components.last, Int(last) != nil, let key = components.first
			else {
				return view?.selection.isEmpty == false
			}

			switch key {
			case "icon", "color":
				guard let selection = view?.selection, cache.validate(.isSection, other: selection) != false else {
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
		case .marked:
			cache.validate(.isMarked, other: selection).state
		case .section:
			cache.validate(.isSection, other: selection).state
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

		let details = DetailsView.Properties.init(text: localization.newItemText)
		let model = DetailsView.Model(navigationTitle: localization.newItemDetailsTitle, properties: details)
		view?.showDetails(with: model) { [weak self] saved, success in
			self?.view?.hideDetails()
			if success {
				let note = saved.description.isEmpty ? nil : saved.description
				let style: ItemStyle = saved.isSection ? .section(icon: saved.icon) : .item

				guard let id = self?.interactor?.newItem(
					saved.text,
					isStrikethrough: saved.isStrikethrough,
					note: note,
					isMarked: saved.isMarked,
					style: style,
					target: target
				) else {
					return
				}
				if let target {
					self?.view?.expand([target])
				}
				self?.view?.scroll(to: id)
			}
		}
	}

	func editItem(with selection: [UUID]) {
		guard let id = selection.first, let item = interactor?.nodes(for: [id]).first?.value else {
			return
		}
		let model = DetailsView.Model(navigationTitle: localization.editItemDetailsTitle, properties: item.details)
		view?.showDetails(with: model) { [weak self] saved, success in
			self?.view?.hideDetails()
			if success {
				let note = saved.description.isEmpty ? nil : saved.description
				let style: ItemStyle = saved.isSection ? .section(icon: saved.icon) : .item

				self?.interactor?.set(
					saved.text,
					isStrikethrough: saved.isStrikethrough,
					note: note,
					isMarked: saved.isMarked,
					style: style,
					for: id
				)
			}
		}
	}

	func toggleStrikethrough(for ids: [UUID]) {
		let completionBehaviour = settingsProvider.state.completionBehaviour
		let moveToEnd = completionBehaviour == .moveToEnd
		let status = cache.validate(.isStrikethrough, other: ids) ?? false
		interactor?.setStatus(!status, for: ids, moveToEnd: moveToEnd)
	}

	func toggleMark(for ids: [UUID]) {
		let markingBehaviour = settingsProvider.state.markingBehaviour
		let moveToTop = markingBehaviour == .moveToTop
		let mark = cache.validate(.isMarked, other: ids) ?? false
		interactor?.setMark(!mark, for: ids, moveToTop: moveToTop)
	}

	func toggleNote(for ids: [UUID]) {
		let hasNote = cache.validate(.hasNote, other: ids) ?? false
		interactor?.set(note: !hasNote ? localization.newNoteText : nil, for: ids)
		if !hasNote, let first = ids.first {
			view?.focus(on: first, key: "subtitle")
		}
	}

	func toggleStyle(for ids: [UUID]) {
		let isSection = cache.validate(.isSection, other: ids) ?? false
		interactor?.setStyle(isSection ? .item : .section(icon: nil), for: ids)
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

	func validateMark() -> Bool? {
		guard let selection = view?.selection, !selection.isEmpty else {
			return false
		}
		return cache.validate(.isMarked, other: selection)
	}

	func validateStyle(_ style: Item.Style) -> Bool? {
		guard let selection = view?.selection, !selection.isEmpty else {
			return false
		}
		switch style {
		case .item:
			return cache.validate(.isItem, other: selection)
		case .section:
			return cache.validate(.isSection, other: selection)
		}
	}
}

enum Property: Hashable {
	case isStrikethrough
	case isMarked
	case isItem
	case isSection
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

	var details: DetailsView.Properties {
		return .init(
			text: text,
			description: note ?? "",
			isStrikethrough: isStrikethrough,
			isMarked: isMarked,
			isSection: style != .item,
			icon: style.icon
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

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
}

final class ContentPresenter {

	// MARK: - DI

	var interactor: ContentInteractorProtocol?

	weak var view: UnitView?

	private(set) var factory: ItemsFactoryProtocol = ItemsFactory()

	private(set) var localization: ContentLocalizationProtocol

	// MARK: - Constants

	private let stringType = NSPasteboard.PasteboardType.string.rawValue

	var settingsProvider: any StateProviderProtocol<Settings>

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

		var snapshot = Snapshot(content.root.nodes)
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

		view?.display(converted)
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

	func menuItemClicked(_ item: ElementIdentifier) {
		guard let selection = view?.selection else {
			return
		}

		switch item {
		case .newItem:		newItem(in: selection)
		case .completed:	toggleStrikethrough(for: selection)
		case .marked:		toggleMark(for: selection)
		case .note:			toggleNote(for: selection)
		case .delete:		delete(ids: selection)
		case .cut:			cut(ids: selection)
		case .copy:			copy(ids: selection)
		case .paste:		paste(ids: selection)
		case .section:		setStyle(style: .section(icon: nil), for: selection)
		case .plainItem:	setStyle(style: .item, for: selection)
		case .noIcon:		setStyle(style: .section(icon: nil), for: selection)
		default:
			let components = item.rawValue.split(separator: "-")
			guard
				components.count == 2, components.first == "icon",
				let last = components.last, let index = Int(last)
			else {
				fatalError("Undefined menu item: \(item)")
			}
			interactor?.setStyle(.section(icon: ItemIcon(rawValue: index)), for: selection)
		}
	}
	
	func validateMenuItem(_ item: ElementIdentifier) -> Bool {
		switch item {
		case .newItem:
			return true
		case .paste:
			let types = Set([stringType])
			let pasteboard = Pasteboard(pasteboard: NSPasteboard.general)
			return pasteboard.contains(types)			
		default:
			return view?.selection.isEmpty == false
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
		guard let interactor else {
			return
		}
		let first = selection.first
		let id = interactor.newItem(localization.newItemText, target: first)

		view?.scroll(to: id)
		if let first {
			view?.expand([first])
		}
		view?.focus(on: id, key: "title")
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

	func setStyle(style: ItemStyle, for ids: [UUID]) {
		interactor?.setStyle(style, for: ids)
	}

	func delete(ids: [UUID]) {
		interactor?.deleteItems(ids)
	}
}

// MARK: - Support Pasteboard
private extension ContentPresenter {

	func cut(ids: [UUID]) {
		guard
			let selection = view?.selection,
			let interactor, !selection.isEmpty
		else {
			return
		}

		let strings = interactor.strings(for: selection)

		let items = strings.map { string in
			PasteboardInfo.Item(string: string)
		}

		let info = PasteboardInfo(items: items)

		let pasteboard = Pasteboard(pasteboard: NSPasteboard.general)
		pasteboard.setInfo(info, clearContents: true)
		interactor.deleteItems(selection)
	}

	func copy(ids: [UUID]) {
		guard
			let selection = view?.selection,
			let interactor, !selection.isEmpty
		else {
			return
		}

		let strings = interactor.strings(for: selection)

		let items = strings.map { string in
			PasteboardInfo.Item(string: string)
		}

		let info = PasteboardInfo(items: items)

		let pasteboard = Pasteboard(pasteboard: NSPasteboard.general)
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

		let strings = info.items.compactMap { item in
			item.data[stringType]
		}.compactMap { data in
			String(data: data, encoding: .utf8)
		}

		interactor?.insertStrings(strings, to: destination)
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
		info.containsInfo(of: stringType)
	}

	func drop(_ info: PasteboardInfo, to destination: Destination<UUID>) {

		let strings = info.items.compactMap { item in
			item.data[stringType]
		}.compactMap { data in
			String(data: data, encoding: .utf8)
		}

		interactor?.insertStrings(strings, to: destination)
	}
}

// MARK: - DragDelegate
extension ContentPresenter: DragDelegate {

	func write(ids: [UUID], to pasteboard: any PasteboardProtocol) {
		guard let strings = interactor?.strings(for: ids) else {
			return
		}

		let items = strings.map { string in
			PasteboardInfo.Item(string: string)
		}

		let info = PasteboardInfo(items: items)
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
extension ContentPresenter {

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

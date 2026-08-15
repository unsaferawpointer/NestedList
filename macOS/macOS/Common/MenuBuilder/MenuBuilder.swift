//
//  MenuBuilder.swift
//  macOS
//
//  Created by Anton Cherkasov on 17.11.2024.
//

import Cocoa
import CoreModule
import DesignSystem
import CorePresentation

@MainActor
protocol MenuBuilderProtocol {
	static func build(for items: [ContentMenuIdentifier], target: AnyObject?, source: MenuSource) -> NSMenu
	static func build(for items: [ColumnMenuIdentifier], target: AnyObject?, source: MenuSource) -> NSMenu
}

@MainActor
final class MenuBuilder { }

// MARK: - MenuBuilderProtocol
extension MenuBuilder: MenuBuilderProtocol {

	static func build(for items: [ContentMenuIdentifier], target: AnyObject?, source: MenuSource) -> NSMenu {
		let menu = NSMenu()
		menu.identifier = .init(source.rawValue)
		for item in items {
			menu.addItem(build(id: item, target: target, source: source))
		}
		return menu
	}

	static func build(for items: [ColumnMenuIdentifier], target: AnyObject?, source: MenuSource) -> NSMenu {
		let menu = NSMenu()
		menu.identifier = .init(source.rawValue)
		for item in items {
			menu.addItem(build(id: item, target: target, source: source))
		}
		return menu
	}
}

// MARK: - Helpers
private extension MenuBuilder {

	static func build(id: ContentMenuIdentifier, target: AnyObject? = nil, source: MenuSource) -> NSMenuItem {

		let action = #selector(MenuSupportable.menuItemClicked(_:))

		let item = NSMenuItem()
		item.action = action
		item.target = target
		item.representedObject = source.rawValue

		switch id {
		case .newItem:
			item.identifier = .init(id.rawValue)
			item.title = MenuLocalization.newItemTitle
			item.keyEquivalent = "t"
			item.image = NSImage(systemSymbolName: "plus", accessibilityDescription: nil)
		case .toggleStrikethrough:
			item.identifier = .init(id.rawValue)
			item.title = MenuLocalization.strikethroughItemTitle
			item.keyEquivalent = "\r"
		case .toggleSubitemsVisibility:
			item.identifier = .init(id.rawValue)
			item.title = MenuLocalization.hideSubitemsItemTitle
		case .appearanceHeader:
			return NSMenuItem.sectionHeader(title: MenuLocalization.appearanceHeaderItemTitle)
		case .changeIcon:
			configureIconItem(item, id: id)
		case .changeColor:
			configureColorItem(item, id: id)
		case .toggleNote:
			item.identifier = .init(id.rawValue)
			item.title = MenuLocalization.noteItemTitle
			item.image = NSImage(systemSymbolName: "note.text", accessibilityDescription: nil)
		case .deleteItems:
			item.identifier = .init(id.rawValue)
			item.title = MenuLocalization.deleteItemTitle
			item.keyEquivalent = "\u{0008}"
			item.image = NSImage(systemSymbolName: "trash", accessibilityDescription: nil)
			return item
		case .editItem:
			item.identifier = .init(id.rawValue)
			item.title = MenuLocalization.editItemTitle
			item.image = NSImage(systemSymbolName: "square.and.pencil", accessibilityDescription: nil)
			return item
		case .separator:
			return NSMenuItem.separator()
		case .cutItems, .copyItems, .paste:
			fatalError()
		}

		return item
	}

	static func build(id: ColumnMenuIdentifier, target: AnyObject? = nil, source: MenuSource) -> NSMenuItem {

		let action = #selector(MenuSupportable.menuItemClicked(_:))

		let item = NSMenuItem()
		item.action = action
		item.target = target
		item.representedObject = source.rawValue

		switch id {
		case .columnNew:
			item.identifier = .init(id.rawValue)
			item.title = MenuLocalization.newItemTitle
			item.image = NSImage(systemSymbolName: "plus", accessibilityDescription: nil)
		case .columnEdit:
			item.identifier = .init(id.rawValue)
			item.title = MenuLocalization.editItemTitle
			item.image = NSImage(systemSymbolName: "square.and.pencil", accessibilityDescription: nil)
			return item
		case .columnDelete:
			item.identifier = .init(id.rawValue)
			item.title = MenuLocalization.deleteItemTitle
			item.image = NSImage(systemSymbolName: "trash", accessibilityDescription: nil)
			return item
		case .moveForward:
			item.identifier = .init(id.rawValue)
			item.title = MenuLocalization.moveForward
			item.image = NSImage(systemSymbolName: "arrow.forward", accessibilityDescription: nil)
			return item
		case .moveBackward:
			item.identifier = .init(id.rawValue)
			item.title = MenuLocalization.moveBackward
			item.image = NSImage(systemSymbolName: "arrow.backward", accessibilityDescription: nil)
			return item
		case .separator:
			return NSMenuItem.separator()
		}

		return item
	}

	static func configureColorItem(_ item: NSMenuItem, id: ContentMenuIdentifier) {
		item.title = MenuLocalization.colorItemTitle
		item.identifier = .init(id.rawValue)
		item.image = NSImage(systemSymbolName: "paintpalette", accessibilityDescription: nil)
	}

	static func configureIconItem(_ item: NSMenuItem, id: ContentMenuIdentifier) {
		item.identifier = .init(id.rawValue)
		item.title = MenuLocalization.iconItemTitle
		item.image = NSImage(systemSymbolName: "photo", accessibilityDescription: nil)
	}
}


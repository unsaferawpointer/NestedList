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
	static func build(for items: [ElementIdentifier], target: AnyObject?) -> NSMenu
}

@MainActor
final class MenuBuilder { }

// MARK: - Helpers
private extension MenuBuilder {

	static func build(id: ElementIdentifier, target: AnyObject? = nil) -> NSMenuItem {

		let action = #selector(ContentViewController.menuItemClicked(_:))

		let item = NSMenuItem()
		item.action = action
		item.target = target

		switch id {
		case .newItem:
			item.identifier = .init(elementIdentifier: .newItem)
			item.title = MenuLocalization.newItemTitle
			item.keyEquivalent = "t"
			item.image = NSImage(systemSymbolName: "plus", accessibilityDescription: nil)
		case .completed:
			item.identifier = .init(elementIdentifier: .completed)
			item.title = MenuLocalization.strikethroughItemTitle
			item.keyEquivalent = "\r"
		case .appearanceHeader:
			return NSMenuItem.sectionHeader(title: MenuLocalization.appearanceHeaderItemTitle)
		case .icon:
			configureIconItem(item)
		case .color:
			configureColorItem(item)
		case .note:
			item.identifier = .init(elementIdentifier: .note)
			item.title = MenuLocalization.noteItemTitle
			item.image = NSImage(systemSymbolName: "note.text", accessibilityDescription: nil)
		case .delete:
			item.identifier = .init(elementIdentifier: .delete)
			item.title = MenuLocalization.deleteItemTitle
			item.keyEquivalent = "\u{0008}"
			item.image = NSImage(systemSymbolName: "trash", accessibilityDescription: nil)
			return item
		case .edit:
			item.identifier = .init(elementIdentifier: .edit)
			item.title = MenuLocalization.editItemTitle
			item.image = NSImage(systemSymbolName: "square.and.pencil", accessibilityDescription: nil)
			return item
		case .separator:
			return NSMenuItem.separator()
		default:
			fatalError()
		}

		return item
	}
}

// MARK: - MenuBuilderProtocol
extension MenuBuilder: MenuBuilderProtocol {

	static func build(for items: [ElementIdentifier], target: AnyObject?) -> NSMenu {
		let menu = NSMenu()
		menu.identifier = .init("outline_context_menu")
		for item in items {
			menu.addItem(build(id: item, target: target))
		}
		return menu
	}
}

// MARK: - Helpers
private extension MenuBuilder {

	static func configureColorItem(_ item: NSMenuItem) {
		item.title = MenuLocalization.colorItemTitle
		item.identifier = .init(elementIdentifier: .color)
		item.image = NSImage(systemSymbolName: "paintpalette", accessibilityDescription: nil)
	}
}

// MARK: - Helpers
private extension MenuBuilder {

	static func configureIconItem(_ item: NSMenuItem) {
		item.identifier = .init(elementIdentifier: .icon)
		item.title = MenuLocalization.iconItemTitle
		item.image = NSImage(systemSymbolName: "photo", accessibilityDescription: nil)
	}
}

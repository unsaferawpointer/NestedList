//
//  MenuBuilder.swift
//  macOS
//
//  Created by Anton Cherkasov on 17.11.2024.
//

import Cocoa

protocol MenuBuilderProtocol {
	static func build() -> NSMenu
}

final class MenuBuilder { }

// MARK: - MenuBuilderProtocol
extension MenuBuilder: MenuBuilderProtocol {

	static func build() -> NSMenu {

		let localization = MenuLocalization()

		let menu = NSMenu(title: localization.editorMenuTitle)

		let action = #selector(ContentViewController.menuItemClicked(_:))

		menu.addItem(
			{
				let item = NSMenuItem()
				item.identifier = .init(elementIdentifier: .newItem)
				item.title = localization.newItemTitle
				item.action = action
				item.keyEquivalent = "t"
				item.image = NSImage(systemSymbolName: "plus", accessibilityDescription: nil)
				return item
			}()
		)
		menu.addItem(.separator())
		if #available(macOS 14.0, *) {
			menu.addItem(NSMenuItem.sectionHeader(title: localization.propertiesHeaderTitle))
		}
		menu.addItem(
			{
				let item = NSMenuItem()
				item.identifier = .init(elementIdentifier: .completed)
				item.title = localization.strikethroughItemTitle
				item.action = action
				item.keyEquivalent = "\r"
				return item
			}()
		)
		menu.addItem(
			{
				let item = NSMenuItem()
				item.identifier = .init(elementIdentifier: .marked)
				item.title = localization.markedItemTitle
				item.action = action
				item.keyEquivalent = ""
				return item
			}()
		)
		menu.addItem(
			{
				let item = NSMenuItem()
				item.identifier = .init(elementIdentifier: .section)
				item.title = localization.sectionItemTitle
				item.action = action
				item.keyEquivalent = ""
				return item
			}()
		)
		menu.addItem(.separator())
		menu.addItem(
			{
				let item = NSMenuItem()
				item.identifier = .init(elementIdentifier: .note)
				item.title = localization.noteItemTitle
				item.action = action
				item.keyEquivalent = ""
				return item
			}()
		)
		menu.addItem(.separator())
		menu.addItem(
			{
				let item = NSMenuItem()
				item.identifier = .init(elementIdentifier: .delete)
				item.title = localization.deleteItemTitle
				item.action = action
				item.keyEquivalent = "\u{0008}"
				item.image = NSImage(systemSymbolName: "trash", accessibilityDescription: nil)
				return item
			}()
		)

		return menu
	}
}

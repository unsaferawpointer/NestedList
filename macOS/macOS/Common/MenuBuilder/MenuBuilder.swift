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

		let menu = NSMenu(title: "Editor")

		let action = #selector(ContentViewController.menuItemClicked(_:))

		menu.addItem(
			{
				let item = NSMenuItem()
				item.identifier = .init(elementIdentifier: .newItem)
				item.title = "New Item"
				item.action = action
				item.keyEquivalent = "t"
				item.image = NSImage(systemSymbolName: "plus", accessibilityDescription: nil)
				return item
			}()
		)
		menu.addItem(.separator())
		if #available(macOS 14.0, *) {
			menu.addItem(NSMenuItem.sectionHeader(title: "Properties"))
		}
		menu.addItem(
			{
				let item = NSMenuItem()
				item.identifier = .init(elementIdentifier: .completed)
				item.title = "Strikethrough"
				item.action = action
				item.keyEquivalent = "\r"
				return item
			}()
		)
		menu.addItem(
			{
				let item = NSMenuItem()
				item.identifier = .init(elementIdentifier: .marked)
				item.title = "Marked"
				item.action = action
				item.keyEquivalent = ""
				return item
			}()
		)
		menu.addItem(
			{
				let item = NSMenuItem()
				item.identifier = .init(elementIdentifier: .section)
				item.title = "Section"
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
				item.title = "Note"
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
				item.title = "Delete"
				item.action = action
				item.keyEquivalent = "\u{0008}"
				item.image = NSImage(systemSymbolName: "trash", accessibilityDescription: nil)
				return item
			}()
		)

		return menu
	}
}

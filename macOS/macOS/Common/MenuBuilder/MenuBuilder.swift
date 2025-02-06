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

		menu.addItem(
			{
				let item = NSMenuItem()
				item.title = "New Item"
				item.action = #selector(MenuSupportable.newItem(_:))
				item.keyEquivalent = "t"
				item.image = NSImage(systemSymbolName: "plus", accessibilityDescription: nil)
				return item
			}()
		)
		menu.addItem(.separator())
		menu.addItem(
			withTitle: "Completed",
			action: #selector(MenuSupportable.toggleStatus(_:)),
			keyEquivalent: "\r"
		)
		menu.addItem(
			withTitle: "Marked",
			action: #selector(MenuSupportable.toggleMark(_:)),
			keyEquivalent: ""
		)
		menu.addItem(.separator())
		menu.addItem(
			withTitle: "Add Note",
			action: #selector(MenuSupportable.addNote(_:)),
			keyEquivalent: ""
		)
		menu.addItem(
			withTitle: "Delete Note",
			action: #selector(MenuSupportable.deleteNote(_:)),
			keyEquivalent: ""
		)
		menu.addItem(.separator())
		menu.addItem(
			{
				let item = NSMenuItem()
				item.title = "Style"
				item.submenu = {
					let menu = NSMenu()
					menu.addItem(
						{
							let item = NSMenuItem()
							item.title = "Item"
							item.action = #selector(MenuSupportable.setItemStyle(_:))
							item.keyEquivalent = ""
							item.tag = 0
							return item
						}()
					)
					menu.addItem(
						{
							let item = NSMenuItem()
							item.title = "Section"
							item.action = #selector(MenuSupportable.setItemStyle(_:))
							item.keyEquivalent = ""
							item.tag = 1
							return item
						}()
					)
					return menu
				}()
				return item
			}()
		)
		menu.addItem(.separator())
		menu.addItem(
			{
				let item = NSMenuItem()
				item.title = "Delete"
				item.action = #selector(MenuSupportable.deleteItem(_:))
				item.keyEquivalent = "\u{0008}"
				item.image = NSImage(systemSymbolName: "trash", accessibilityDescription: nil)
				return item
			}()
		)

		return menu
	}
}

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

final class MenuBuilder {

}

// MARK: - MenuBuilderProtocol
extension MenuBuilder: MenuBuilderProtocol {

	static func build() -> NSMenu {

		let menu = NSMenu(title: "Editor")

		menu.addItem(
			NSMenuItem(
				title: "New Item",
				action: #selector(MenuSupportable.newItem(_:)),
				keyEquivalent: "t"
			)
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
			NSMenuItem(
				title: "Delete",
				action: #selector(MenuSupportable.deleteItem(_:)),
				keyEquivalent: "\u{0008}"
			)
		)

		return menu
	}
}

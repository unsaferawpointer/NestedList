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

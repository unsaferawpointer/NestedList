//
//  MenuBuilder.swift
//  macOS
//
//  Created by Anton Cherkasov on 17.11.2024.
//

import Cocoa
import CoreModule
import DesignSystem

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
				item.action = action
				item.title = localization.sectionItemTitle
				return item
			}()
		)
		menu.addItem(.separator())
		menu.addItem(
			{
				let item = NSMenuItem()
				item.identifier = .init(elementIdentifier: .icon)
				item.title = localization.sectionIconItemTitle
				item.submenu = {
					let menu = NSMenu()
					menu.addItem(
						{
							let item = NSMenuItem()
							item.identifier = .init(elementIdentifier: .noIcon)
							item.title = localization.noIconItemTitle
							item.image = NSImage(systemSymbolName: "circle.slash", accessibilityDescription: nil)
							item.action = action
							return item
						}()
					)
					menu.addItem(.separator())
					for icon in IconName.allCases {
						let item = NSMenuItem()
						item.identifier = .init("icon-\(icon.rawValue)")
						item.action = action
						item.title = IconMapper.map(icon: icon, filled: false)?.title ?? ""
						item.image = IconMapper.map(icon: icon, filled: false)?.image
						menu.addItem(item)
					}
					return menu
				}()

				return item
			}()
		)
		menu.addItem(
			{
				let item = NSMenuItem()
				item.title = localization.sectionColorItemTitle
				item.submenu = {
					let menu = NSMenu()
					for color in ItemColor.allCases {

						let token = ColorMapper.map(color: color)

						let item = NSMenuItem()
						item.identifier = .init("color-\(color.rawValue)")
						item.title = token.displayName
						item.action = action
						menu.addItem(item)
						item.image = NSImage(systemSymbolName: "circle.fill", accessibilityDescription: nil)?
							.withSymbolConfiguration(.init(hierarchicalColor: token.value))
					}
					return menu
				}()
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

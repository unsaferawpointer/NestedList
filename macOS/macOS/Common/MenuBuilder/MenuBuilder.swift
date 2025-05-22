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
	static func build(for items: [ElementIdentifier]) -> NSMenu
}

final class MenuBuilder { }

// MARK: - Helpers
private extension MenuBuilder {

	static func build(id: ElementIdentifier) -> NSMenuItem {

		let action = #selector(ContentViewController.menuItemClicked(_:))

		let item = NSMenuItem()
		item.action = action

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
		case .marked:
			item.identifier = .init(elementIdentifier: .marked)
			item.title = MenuLocalization.markedItemTitle
		case .section:
			item.identifier = .init(elementIdentifier: .section)
			item.title = MenuLocalization.sectionItemTitle
		case .icon:
			item.identifier = .init(elementIdentifier: .icon)
			item.title = MenuLocalization.sectionIconItemTitle
			item.submenu = {
				let menu = NSMenu()
				menu.addItem(
					{
						let item = NSMenuItem()
						item.identifier = .init(elementIdentifier: .noIcon)
						item.title = MenuLocalization.noIconItemTitle
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
		case .color:
			item.title = MenuLocalization.sectionColorItemTitle
			item.identifier = .init(elementIdentifier: .color)
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
		case .note:
			item.identifier = .init(elementIdentifier: .note)
			item.title = MenuLocalization.noteItemTitle
		case .delete:
			item.identifier = .init(elementIdentifier: .delete)
			item.title = MenuLocalization.deleteItemTitle
			item.keyEquivalent = "\u{0008}"
			item.image = NSImage(systemSymbolName: "trash", accessibilityDescription: nil)
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

	static func build(for items: [ElementIdentifier]) -> NSMenu {
		let menu = NSMenu()
		for item in items {
			menu.addItem(build(id: item))
		}
		return menu
	}
}

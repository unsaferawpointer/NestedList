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
			configureColorItem(item, action: action)
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
		case .columnNewItem:
			item.identifier = .init(elementIdentifier: .columnEdit)
			item.title = MenuLocalization.newItemTitle
			item.image = NSImage(systemSymbolName: "plus", accessibilityDescription: nil)
		case .columnEdit:
			item.identifier = .init(elementIdentifier: .columnEdit)
			item.title = MenuLocalization.editItemTitle
			item.image = NSImage(systemSymbolName: "square.and.pencil", accessibilityDescription: nil)
			return item
		case .columnDelete:
			item.identifier = .init(elementIdentifier: .columnDelete)
			item.title = MenuLocalization.deleteItemTitle
			item.image = NSImage(systemSymbolName: "trash", accessibilityDescription: nil)
			return item
		case .moveForward:
			item.identifier = .init(elementIdentifier: .moveForward)
			item.title = MenuLocalization.moveForward
			item.image = NSImage(systemSymbolName: "arrow.forward", accessibilityDescription: nil)
			return item
		case .moveBackward:
			item.identifier = .init(elementIdentifier: .moveBackward)
			item.title = MenuLocalization.moveBackward
			item.image = NSImage(systemSymbolName: "arrow.backward", accessibilityDescription: nil)
			return item
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

	static func buildColorItem(color: ItemColor, action: Selector) -> NSMenuItem {

		let token = ColorMapper.map(color: color)

		let item = NSMenuItem()
		item.identifier = .init("color-\(color.rawValue)")
		item.title = token.displayName
		item.action = action
		item.image = NSImage(systemSymbolName: "circle.fill", accessibilityDescription: nil)?
			.withSymbolConfiguration(.init(hierarchicalColor: token.value))

		return item
	}

	static func configureColorItem(_ item: NSMenuItem, action: Selector) {
		item.title = MenuLocalization.colorItemTitle
		item.identifier = .init(elementIdentifier: .color)
		item.image = NSImage(systemSymbolName: "paintpalette", accessibilityDescription: nil)
		item.submenu = {
			let menu = NSMenu()

			menu.addItem(
				{
					let item = NSMenuItem()
					item.identifier = .init(elementIdentifier: .noColor)
					item.title = MenuLocalization.noColorItemTitle
					item.image = NSImage(systemSymbolName: "circle.slash", accessibilityDescription: nil)
					item.action = action
					return item
				}()
			)
			menu.addItem(.separator())

			for group in ColorsPalette.grouped() {
				for color in group {
					let item = buildColorItem(
						color: color,
						action: action
					)
					menu.addItem(item)
				}
				menu.addItem(.separator())
			}
			return menu
		}()
	}
}

// MARK: - Helpers
private extension MenuBuilder {

	static func buildIconItem(icon: IconName, action: Selector, target: AnyObject?) -> NSMenuItem {
		let item = NSMenuItem()
		item.identifier = .init("icon-\(icon.rawValue)")
		item.action = action
		item.target = target
		item.title = IconMapper.map(icon: icon, filled: false)?.title ?? ""
		item.image = IconMapper.map(icon: icon, filled: false)?.nsImage?
			.withSymbolConfiguration(.preferringMonochrome())
		return item
	}

	static func configureIconItem(_ item: NSMenuItem) {
		item.identifier = .init(elementIdentifier: .icon)
		item.title = MenuLocalization.iconItemTitle
		item.image = NSImage(systemSymbolName: "photo", accessibilityDescription: nil)
	}
}

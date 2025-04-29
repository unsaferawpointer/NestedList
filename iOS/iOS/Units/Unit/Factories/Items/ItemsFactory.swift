//
//  ItemsFactory.swift
//  iOS
//
//  Created by Anton Cherkasov on 27.12.2024.
//

import Foundation

import DesignSystem
import CoreModule
import CoreSettings

protocol ItemsFactoryProtocol {
	func makeItem(item: Item, level: Int, isGroup: Bool, iconColor: IconColor) -> ItemModel
}

final class ItemsFactory { }

// MARK: - ItemsFactoryProtocol
extension ItemsFactory: ItemsFactoryProtocol {

	func makeItem(item: Item, level: Int, isGroup: Bool, iconColor: IconColor) -> ItemModel {

		let titleConfiguration: TextConfiguration = switch item.style {
		case .item:
			TextConfiguration(
				text: item.text,
				style: .body,
				colorToken: item.isStrikethrough ? .disabledText : .primary,
				strikethrough: item.isStrikethrough
			)
		case .section:
			TextConfiguration(
				text: item.text,
				style: .headline,
				colorToken: item.isStrikethrough ? .disabledText : .primary,
				strikethrough: item.isStrikethrough
			)
		}

		let subtitleConfiguration: TextConfiguration? = if let note = item.note {
			TextConfiguration(
				text: note,
				style: .callout,
				colorToken: .secondary,
				strikethrough: false
			)
		} else {
			nil
		}

		let iconAppearence: IconAppearence = {
			switch (item.isStrikethrough, item.isMarked) {
			case (true, _):
				return .monochrome(token: .disabledText)
			case (false, true):
				return .hierarchical(token: .yellow)
			case (false, false):
				guard let color = iconColor.color else {
					return .multicolor
				}
				return .monochrome(token: color)
			}
		}()

		let icon: IconName = {
			switch iconColor {
			case .multicolor:
				isGroup ? .named("custom.folder.fill") : .named("custom.text.document.fill")
			default:
				isGroup ? .systemName("folder") : .systemName("text.document")
			}
		}()

		let iconConfiguration: IconConfiguration? = switch item.style {
		case .item:
			IconConfiguration(
				name: .named("point"),
				appearence: .hierarchical(token: item.isMarked && !item.isStrikethrough ? .yellow : .quaternary)
			)
		case .section:
			IconConfiguration(
				name: icon,
				appearence: iconAppearence
			)
		}

		return ItemModel(
			uuid: item.id,
			icon: iconConfiguration,
			title: titleConfiguration,
			subtitle: subtitleConfiguration,
			status: item.isStrikethrough,
			isMarked: item.isMarked,
			isSection: item.style == .section
		)
	}
}

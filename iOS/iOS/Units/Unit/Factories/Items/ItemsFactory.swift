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

		let iconName = item.style.icon

		let iconAppearence: IconAppearence = {
			switch (item.isStrikethrough, item.isMarked) {
			case (true, _):
				return .monochrome(token: .disabledText)
			case (false, true):
				return .hierarchical(token: .yellow)
			case (false, false):
				guard let color = iconColor.color else {
					return .monochrome(token: iconName?.tintColor ?? .primary)
				}

				return item.style.isSection ? .monochrome(token: color) : .monochrome(token: .tertiary)
			}
		}()

		let iconConfiguration: IconConfiguration? = switch item.style {
		case .item:
			IconConfiguration(
				name: item.style.icon,
				appearence: .hierarchical(token: item.isMarked && !item.isStrikethrough ? .yellow : .quaternary)
			)
		case .section:
			IconConfiguration(
				name: item.style.icon,
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
			isSection: item.style.isSection
		)
	}
}

extension ItemStyle {

	var icon: SemanticImage? {
		switch self {
		case .item:
			return .point
		case let .section(icon):
			return IconMapper.map(icon: icon, filled: false)
		}
	}
}

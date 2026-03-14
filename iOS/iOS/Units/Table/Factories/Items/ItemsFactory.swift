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
import CorePresentation

protocol ItemsFactoryProtocol {
	func makeItem(item: Item, level: Int, iconColor: IconColor) -> ItemModel
}

final class ItemsFactory { }

// MARK: - ItemsFactoryProtocol
extension ItemsFactory: ItemsFactoryProtocol {

	func makeItem(item: Item, level: Int, iconColor: IconColor) -> ItemModel {

		let titleConfiguration = TextConfiguration(
			text: item.text,
			style: level == 0 ? .headline : .body,
			colorToken: item.isStrikethrough ? .disabledText : .primary,
			strikethrough: item.isStrikethrough
		)

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
			switch item.isStrikethrough {
			case true:
				return .monochrome(token: .tertiary)
			case false:
				if let color = iconColor.color {
					return .monochrome(token: color)
				}
				return .hierarchical(token: ColorMapper.map(color: item.tintColor))
			}
		}()

		let iconName = IconMapper.map(icon: item.iconName, filled: true)
		let iconConfiguration: IconConfiguration? = if let iconName {
			IconConfiguration(name: iconName, appearence: iconAppearence)
		} else {
			IconConfiguration(name: .point, appearence: iconAppearence)
		}

		return ItemModel(
			uuid: item.id,
			icon: iconConfiguration,
			title: titleConfiguration,
			subtitle: subtitleConfiguration
		)
	}
}

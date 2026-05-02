//
//  ItemsFactory.swift
//  iOS
//
//  Created by Anton Cherkasov on 27.12.2024.
//

import Foundation

import DesignSystem
import CoreModule
import CorePresentation

protocol ItemsFactoryProtocol {
	func makeItem(item: Item, isLeaf: Bool, iconColor: IconColor) -> ItemModel
}

final class ItemsFactory { }

// MARK: - ItemsFactoryProtocol
extension ItemsFactory: ItemsFactoryProtocol {

	func makeItem(item: Item, isLeaf: Bool, iconColor: IconColor) -> ItemModel {

		let titleConfiguration = TextConfiguration(
			text: item.text,
			style: isLeaf ? .body : .headline,
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

		let iconName = IconMapper.map(icon: item.iconName, filled: true)

		let iconAppearence: IconAppearence = {
			switch item.isStrikethrough {
			case true:
				return .monochrome(token: .tertiary)
			case false:
				if let color = iconColor.color {
					return .monochrome(token: color)
				}
				let token = ColorMapper.map(color: item.tintColor)
				guard let preffered = iconName?.preferredAppearance(with: token) else {
					return .monochrome(token: ColorMapper.map(color: item.tintColor))
				}
				return preffered
			}
		}()

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

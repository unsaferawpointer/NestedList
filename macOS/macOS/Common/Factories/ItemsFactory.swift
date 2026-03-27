//
//  ItemsFactory.swift
//  macOS
//
//  Created by Anton Cherkasov on 24.12.2024.
//

import Foundation
import AppKit

import DesignSystem
import CoreModule
import CoreSettings
import CorePresentation

protocol ItemsFactoryProtocol {
	func makeItem(item: Item, isLeaf: Bool, iconColor: IconColor) -> ItemModel
}

final class ItemsFactory { }

// MARK: - ItemsFactoryProtocol
extension ItemsFactory: ItemsFactoryProtocol {

	func makeItem(item: Item, isLeaf: Bool, iconColor: IconColor) -> ItemModel {

		let textConfiguration = TextConfiguration(
			style: isLeaf ? .body : .headline,
			colorToken: item.isStrikethrough ? .disabledText : .primary,
			strikethrough: item.isStrikethrough
		)

		let iconName = IconMapper.map(icon: item.iconName, filled: true)

		let iconAppearence: IconAppearence = {
			switch (item.isStrikethrough) {
			case true:
				return .monochrome(token: .tertiary)
			case false:
				if let color = iconColor.color {
					return .hierarchical(token: color)
				}
				let token = ColorMapper.map(color: item.tintColor)
				guard let preffered = iconName?.preferredAppearance(with: token) else {
					return .hierarchical(token: ColorMapper.map(color: item.tintColor))
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
			id: item.id,
			value: .init(title: item.text, subtitle: item.note),
			configuration: .init(icon: iconConfiguration, text: textConfiguration),
			isGroup: !isLeaf,
			height: item.note != nil ? 36 : nil
		)
	}
}

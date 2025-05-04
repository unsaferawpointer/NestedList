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

protocol ItemsFactoryProtocol {
	func makeItem(item: Item, level: Int, iconColor: IconColor) -> ItemModel
}

final class ItemsFactory { }

// MARK: - ItemsFactoryProtocol
extension ItemsFactory: ItemsFactoryProtocol {

	func makeItem(item: Item, level: Int, iconColor: IconColor) -> ItemModel {

		let textConfiguration: TextConfiguration = switch item.style {
		case .item:
			TextConfiguration(
				style: .body,
				colorToken: item.isStrikethrough ? .disabledText : .primary,
				strikethrough: item.isStrikethrough
			)
		case .section:
			TextConfiguration(
				style: .headline,
				colorToken: item.isStrikethrough ? .disabledText : .primary,
				strikethrough: item.isStrikethrough
			)
		}

		let iconName = item.style.icon(filled: false)

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

		let iconConfiguration: IconConfiguration? = if let iconName {
			IconConfiguration(name: iconName, appearence: iconAppearence)
		} else {
			nil
		}

		return ItemModel(
			id: item.id,
			value: .init(title: item.text, subtitle: item.note),
			configuration: .init(icon: iconConfiguration, text: textConfiguration),
			isGroup: item.style.isSection,
			height: item.note != nil ? 36 : nil
		)
	}
}

extension ItemStyle {

	func icon(filled: Bool) -> SemanticImage? {
		switch self {
		case .item:
			.point
		case let .section(icon):
			IconMapper.map(icon: icon, filled: filled)
		}
	}
}

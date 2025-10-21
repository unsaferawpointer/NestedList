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
				return .monochrome(token: .tertiary)
			case (false, true):
				return .hierarchical(token: .yellow)
			case (false, false):
				guard item.style != .item else {
					return .monochrome(token: .tertiary)
				}
				if let color = iconColor.color {
					return .monochrome(token: color)
				}
				return .hierarchical(token: ColorMapper.map(color: item.style.color))
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
			IconMapper.map(icon: icon?.name, filled: filled)
		}
	}
}

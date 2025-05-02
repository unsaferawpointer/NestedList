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
	func makeItem(item: Item, level: Int, isGroup: Bool, iconColor: IconColor) -> ItemModel
}

final class ItemsFactory { }

// MARK: - ItemsFactoryProtocol
extension ItemsFactory: ItemsFactoryProtocol {

	func makeItem(item: Item, level: Int, isGroup: Bool, iconColor: IconColor) -> ItemModel {

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

		let pointConfiguration: PointConfiguration? = switch item.style {
		case .item:
			PointConfiguration(color: item.isMarked && !item.isStrikethrough ? .yellow : .quaternary)
		case .section:
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

		let iconConfiguration: IconConfiguration? = if let iconName = item.style.icon {
			IconConfiguration(name: iconName, appearence: iconAppearence)
		} else {
			nil
		}

		return ItemModel(
			id: item.id,
			value: .init(title: item.text, subtitle: item.note),
			configuration: .init(
				point: pointConfiguration,
				icon: iconConfiguration,
				text: textConfiguration
			),
			isGroup: item.style.isSection,
			height: item.note != nil ? 36 : nil
		)
	}
}

extension ItemStyle {

	var icon: SemanticImage? {
		switch self {
		case .item:
			return .point
		case let .section(icon):
			guard let rawValue = icon?.rawValue else {
				return nil
			}
			return SemanticImage(rawValue: rawValue)
		}
	}
}

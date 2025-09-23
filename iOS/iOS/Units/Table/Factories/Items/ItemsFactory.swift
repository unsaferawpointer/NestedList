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
	func makeItem(item: Item, level: Int, iconColor: IconColor) -> ItemModel
}

final class ItemsFactory { }

// MARK: - ItemsFactoryProtocol
extension ItemsFactory: ItemsFactoryProtocol {

	func makeItem(item: Item, level: Int, iconColor: IconColor) -> ItemModel {

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
				return .monochrome(token: ColorMapper.map(color: item.style.color))
			}
		}()

		let iconConfiguration: IconConfiguration? = switch item.style {
		case .item:
			IconConfiguration(
				name: item.style.semanticImage,
				appearence: .hierarchical(token: item.isMarked && !item.isStrikethrough ? .yellow : .quaternary)
			)
		case .section:
			IconConfiguration(
				name: item.style.semanticImage,
				appearence: iconAppearence
			)
		}

		return ItemModel(
			uuid: item.id,
			icon: iconConfiguration,
			title: titleConfiguration,
			subtitle: subtitleConfiguration
		)
	}
}

extension ItemStyle {

	var icon: ItemIcon? {
		switch self {
		case .item:
			return nil
		case .section(let icon):
			return icon
		}
	}

	var semanticImage: SemanticImage? {
		switch self {
		case .item:
			return .point
		case let .section(icon):
			return IconMapper.map(icon: icon?.name, filled: false)
		}
	}
}

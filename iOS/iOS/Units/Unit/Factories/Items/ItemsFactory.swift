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
				colorToken: item.isDone ? .disabledText : .primary,
				strikethrough: item.isDone
			)
		case .section:
			TextConfiguration(
				text: item.text,
				style: .headline,
				colorToken: item.isDone ? .disabledText : .primary,
				strikethrough: item.isDone
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
			switch (item.isDone, item.isMarked) {
			case (true, _):
				return .monochrome(token: .disabledText)
			case (false, true):
				return .monochrome(token: .yellow)
			case (false, false):
				guard let color = iconColor.color else {
					return .monochrome(token: .primary)
				}
				return .hierarchical(token: color)
			}
		}()

		let iconConfiguration: IconConfiguration? = switch item.style {
		case .item:
			IconConfiguration(
				name: .named("point"),
				appearence: .hierarchical(token: item.isMarked && !item.isDone ? .yellow : .quaternary)
			)
		case .section:
			IconConfiguration(
				name: isGroup ? .systemName("document.on.document") : .systemName("text.document"),
				appearence: iconAppearence
			)
		}

		return ItemModel(
			uuid: item.id,
			icon: iconConfiguration,
			title: titleConfiguration,
			subtitle: subtitleConfiguration,
			status: item.isDone,
			isMarked: item.isMarked,
			isSection: item.style == .section
		)
	}
}

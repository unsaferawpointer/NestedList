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
				colorToken: item.isDone ? .disabledText : .primary,
				strikethrough: item.isDone
			)
		case .section:
			TextConfiguration(
				style: .headline,
				colorToken: item.isDone ? .disabledText : .primary,
				strikethrough: item.isDone
			)
		}

		let pointConfiguration: PointConfiguration? = switch item.style {
		case .item:
			PointConfiguration(color: item.isMarked && !item.isDone ? .yellow : .quaternary)
		case .section:
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
				return .monochrome(token: color)
			}
		}()

		let iconConfiguration: IconConfiguration? = switch item.style {
		case .item:
			nil
		case .section:
			IconConfiguration(
				name: isGroup ? .systemName("document.on.document") : .systemName("text.document"),
				appearence: iconAppearence
			)
		}

		return ItemModel(
			id: item.id,
			value: .init(title: item.text, subtitle: item.note),
			configuration: .init(
				point: pointConfiguration,
				icon: iconConfiguration,
				text: textConfiguration
			),
			isGroup: item.style == .section,
			height: item.note != nil ? 36 : nil
		)
	}
}

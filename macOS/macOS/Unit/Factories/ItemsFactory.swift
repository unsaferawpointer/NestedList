//
//  ItemsFactory.swift
//  macOS
//
//  Created by Anton Cherkasov on 24.12.2024.
//

import Foundation
import AppKit
import CoreModule

protocol ItemsFactoryProtocol {
	func makeItem(item: Item, isDone: Bool, level: Int) -> ItemModel
}

final class ItemsFactory { }

// MARK: - ItemsFactoryProtocol
extension ItemsFactory: ItemsFactoryProtocol {

	func makeItem(item: Item, isDone: Bool, level: Int) -> ItemModel {

		let textConfiguration: TextConfiguration = switch item.style {
		case .item:
			TextConfiguration(
				style: .body,
				colorToken: isDone ? .secondary : .primary,
				strikethrough: isDone
			)
		case .section:
			TextConfiguration(
				style: .headline,
				colorToken: isDone ? .secondary : .primary,
				strikethrough: isDone
			)
		}

		let pointConfiguration: PointConfiguration? = switch item.style {
		case .item:
			PointConfiguration(color: .tertiary)
		case .section:
			nil
		}

		let iconConfiguration: IconConfiguration? = switch item.style {
		case .item:
			nil
		case .section:
			IconConfiguration(iconName: "doc.text", color: isDone ? .secondary : .primary)
		}

		return ItemModel(
			id: item.id,
			value: .init(text: item.text),
			configuration: .init(
				point: pointConfiguration,
				icon: iconConfiguration,
				text: textConfiguration
			),
			isGroup: level == 0 && item.style == .section
		)
	}
}

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

protocol ItemsFactoryProtocol {
	func makeItem(item: Item, level: Int) -> ItemModel
}

final class ItemsFactory { }

// MARK: - ItemsFactoryProtocol
extension ItemsFactory: ItemsFactoryProtocol {

	func makeItem(item: Item, level: Int) -> ItemModel {

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

		let iconConfiguration: IconConfiguration? = switch item.style {
		case .item:
			nil
		case .section:
			IconConfiguration(
				name: .systemName("doc.text"),
				token: item.isMarked && !item.isDone ? .yellow : .tertiary
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
			isGroup: level == 0 && item.style == .section,
			height: item.note != nil ? 36 : nil
		)
	}
}

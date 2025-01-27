//
//  ItemsFactory.swift
//  iOS
//
//  Created by Anton Cherkasov on 27.12.2024.
//

import Foundation
import DesignSystem
import CoreModule

protocol ItemsFactoryProtocol {
	func makeItem(item: Item, isDone: Bool, level: Int) -> ItemModel
}

final class ItemsFactory { }

// MARK: - ItemsFactoryProtocol
extension ItemsFactory: ItemsFactoryProtocol {

	func makeItem(item: Item, isDone: Bool, level: Int) -> ItemModel {

		let titleConfiguration: TextConfiguration = switch item.style {
		case .item:
			TextConfiguration(
				text: item.text,
				style: .body,
				colorToken: isDone ? .disabledText : .primary,
				strikethrough: isDone
			)
		case .section:
			TextConfiguration(
				text: item.text,
				style: .headline,
				colorToken: isDone ? .disabledText : .primary,
				strikethrough: isDone
			)
		}

		let iconConfiguration: IconConfiguration = switch item.style {
		case .item:
			IconConfiguration(
				name: .named("point"),
				token: item.isMarked && !isDone ? .yellow : .quaternary
			)
		case .section:
			IconConfiguration(
				name: .systemName("doc.text"),
				token: item.isMarked && !isDone ? .yellow : .tertiary
			)
		}

		return ItemModel(
			uuid: item.id,
			icon: iconConfiguration,
			title: titleConfiguration,
			subtitle: nil,
			status: isDone,
			isMarked: item.isMarked
		)
	}
}

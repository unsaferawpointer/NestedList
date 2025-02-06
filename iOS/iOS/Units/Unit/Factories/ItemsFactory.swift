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
	func makeItem(item: Item, level: Int) -> ItemModel
}

final class ItemsFactory { }

// MARK: - ItemsFactoryProtocol
extension ItemsFactory: ItemsFactoryProtocol {

	func makeItem(item: Item, level: Int) -> ItemModel {

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

		let iconConfiguration: IconConfiguration = switch item.style {
		case .item:
			IconConfiguration(
				name: .named("point"),
				token: item.isMarked && !item.isDone ? .yellow : .quaternary
			)
		case .section:
			IconConfiguration(
				name: .systemName("doc.text"),
				token: item.isMarked && !item.isDone ? .yellow : .tertiary
			)
		}

		return ItemModel(
			uuid: item.id,
			icon: iconConfiguration,
			title: titleConfiguration,
			subtitle: subtitleConfiguration,
			status: item.isDone,
			isMarked: item.isMarked
		)
	}
}

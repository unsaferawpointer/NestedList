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

		let textColor: ColorToken = switch item.style {
		case .item:
			isDone ? .secondary : .primary
		case .section:
			.primary
		}

		return ItemModel(
			uuid: item.id,
			textColor: textColor,
			strikethrough: isDone,
			style: item.style.modelStyle,
			text: item.text,
			status: isDone
		)
	}
}

// MARK: - Computed properties
fileprivate extension Item.Style {

	var modelStyle: ItemModel.Style {
		switch self {
		case .item:		.point(.secondary)
		case .section:	.section
		}
	}
}


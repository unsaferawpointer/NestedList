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

		let textColor: NSColor = switch item.style {
		case .item:
			isDone ? .tertiaryLabelColor : .labelColor
		case .section:
			isDone ? .tertiaryLabelColor : .labelColor
		}

		return ItemModel(
			id: item.id,
			value: .init(text: item.text),
			configuration: .init(
				textColor: textColor,
				strikethrough: isDone,
				style: item.style.modelStyle
			),
			isGroup: level == 0 && item.style == .section
		)
	}
}

// MARK: - Computed properties
fileprivate extension Item.Style {

	var modelStyle: ItemModel.Style {
		switch self {
		case .item:		.point(.secondarySystemFill)
		case .section:	.section
		}
	}
}

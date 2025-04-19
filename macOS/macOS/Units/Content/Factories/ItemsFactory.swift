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
	func makeItem(item: Item, level: Int, sectionStyle: SectionStyle) -> ItemModel
}

final class ItemsFactory { }

// MARK: - ItemsFactoryProtocol
extension ItemsFactory: ItemsFactoryProtocol {

	func makeItem(item: Item, level: Int, sectionStyle: SectionStyle) -> ItemModel {

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
			sectionStyle == .point
			? PointConfiguration(color: item.isMarked && !item.isDone ? .yellow : .quaternary)
			: nil
		}

		let iconConfiguration: IconConfiguration? = switch item.style {
		case .item:
			nil
		case .section:
			sectionStyle == .icon
			? IconConfiguration(
				name: level == 0 ? .named("custom.folder.fill") : .named("custom.document.on.document.fill"),
				appearence: .hierarchical(token: item.isMarked && !item.isDone ? .yellow : level == 0 ? .cyan : .gray)
			)
			: nil
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

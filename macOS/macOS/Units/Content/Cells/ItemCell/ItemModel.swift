//
//  ItemModel.swift
//  macOS
//
//  Created by Anton Cherkasov on 16.11.2024.
//

import DesignSystem
import Cocoa
import CorePresentation

struct ItemModel: CellModel {

	typealias Cell = ItemCell

	var id: UUID

	var value: Value

	var configuration: Configuration

	var isGroup: Bool

	var height: CGFloat?

	func contentIsEquals(to other: ItemModel) -> Bool {
		return value == other.value && configuration == other.configuration
	}

}

// MARK: - Initialization
extension ItemModel {

	init(presentation: ItemPresentation) {
		self.init(
			id: presentation.id,
			value: .init(
				title: presentation.title.value,
				subtitle: presentation.subtitle?.value
			),
			configuration: .init(presentation: presentation),
			isGroup: presentation.isGroup,
			height: presentation.subtitle == nil ? nil : 36
		)
	}
}

// MARK: - Nested data structs
extension ItemModel {

	struct Configuration: Equatable {
		var icon: IconConfiguration?
		var badge: IconConfiguration?
		var text: TextConfiguration
		var showsTrailingDisclosure: Bool
	}

	struct Value: Equatable {
		var title: String
		var subtitle: String?
	}
}

// MARK: - Initialization
extension ItemModel.Configuration {

	init(presentation: ItemPresentation) {
		self.init(
			icon: presentation.icon,
			badge: presentation.badge,
			text: .init(
				style: presentation.title.style,
				colorToken: presentation.title.colorToken,
				strikethrough: presentation.title.strikethrough
			),
			showsTrailingDisclosure: presentation.showsTrailingDisclosure
		)
	}
}

struct TextConfiguration: Equatable {
	var style: TextStyle
	var colorToken: ColorToken
	var strikethrough: Bool
}

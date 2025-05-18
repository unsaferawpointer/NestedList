//
//  ItemModel.swift
//  macOS
//
//  Created by Anton Cherkasov on 16.11.2024.
//

import DesignSystem
import Cocoa

struct ItemModel: CellModel {

	typealias Cell = ItemCell

	var id: UUID

	var value: Value

	var configuration: Configuration

	var action: ((Value) -> Void)?

	var isGroup: Bool

	var height: CGFloat?

	func contentIsEquals(to other: ItemModel) -> Bool {
		return value == other.value && configuration == other.configuration
	}

}

// MARK: - Nested data structs
extension ItemModel {

	struct Configuration: Equatable {
		var icon: IconConfiguration?
		var text: TextConfiguration
	}

	struct Value: Equatable {
		var title: String
		var subtitle: String?
	}
}

struct TextConfiguration: Equatable {
	var style: NSFont.TextStyle
	var colorToken: ColorToken
	var strikethrough: Bool
}

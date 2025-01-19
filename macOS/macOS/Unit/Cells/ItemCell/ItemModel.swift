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

}

// MARK: - Nested data structs
extension ItemModel {

	struct Configuration {
		var point: PointConfiguration?
		var icon: IconConfiguration?
		var text: TextConfiguration
	}

	struct Value {
		var text: String
	}
}

struct TextConfiguration {
	var style: NSFont.TextStyle
	var colorToken: ColorToken
	var strikethrough: Bool
}

struct PointConfiguration {
	var color: ColorToken
}

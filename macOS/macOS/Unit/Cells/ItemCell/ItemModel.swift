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

}

// MARK: - Nested data structs
extension ItemModel {

	struct Configuration {
		var textColor: NSColor
		var strikethrough: Bool
	}

	struct Value {
		var text: String
	}
}

//
//  ItemModel.swift
//  iOS
//
//  Created by Anton Cherkasov on 22.11.2024.
//

import Foundation
import DesignSystem

struct ItemModel {

	var uuid: UUID

	var textColor: ColorToken

	var icon: IconConfiguration?

	var strikethrough: Bool

	var style: Style

	var text: String

	var status: Bool

}

// MARK: - Identifiable
extension ItemModel: Identifiable {

	var id: UUID {
		uuid
	}
}

// MARK: - Hashable
extension ItemModel: Hashable { }

// MARK: - Nested data structs
extension ItemModel {

	enum Style: Hashable {
		case point(_ color: ColorToken)
		case section
	}
}

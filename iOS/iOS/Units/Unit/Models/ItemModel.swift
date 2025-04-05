//
//  ItemModel.swift
//  iOS
//
//  Created by Anton Cherkasov on 22.11.2024.
//

import Foundation
import UIKit
import DesignSystem

struct ItemModel {

	var uuid: UUID

	var icon: IconConfiguration?

	var title: TextConfiguration

	var subtitle: TextConfiguration?

	var status: Bool

	var isMarked: Bool

	var isSection: Bool
}

// MARK: - Identifiable
extension ItemModel: Identifiable {

	var id: UUID {
		uuid
	}
}

// MARK: - Hashable
extension ItemModel: Hashable { }

struct TextConfiguration: Hashable {
	var text: String
	var style: UIFont.TextStyle
	var colorToken: ColorToken
	var strikethrough: Bool
}

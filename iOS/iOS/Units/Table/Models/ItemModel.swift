//
//  ItemModel.swift
//  iOS
//
//  Created by Anton Cherkasov on 22.11.2024.
//

import Foundation
import UIKit
import Hierarchy
import DesignSystem

struct ItemModel {

	var uuid: UUID

	var icon: IconConfiguration?

	var title: TextConfiguration

	var subtitle: TextConfiguration?

	var showsTrailingDisclosure: Bool
}

// MARK: - MutableIdentifiable
extension ItemModel: MutableIdentifiable {

	var id: UUID {
		get { uuid }
		set { uuid = newValue }
	}
}

// MARK: - CellModel
extension ItemModel: CellModel {

	var selectionConfiguration: ItemConfiguration { configuration }

	var configuration: ItemConfiguration {
		ItemConfiguration(
			icon: icon,
			title: title,
			subtitle: subtitle,
			showsTrailingDisclosure: showsTrailingDisclosure
		)
	}

	typealias Cell = ItemCell<ItemModel>

	func contentIsEquals(to other: ItemModel) -> Bool {
		return other.configuration == configuration
	}
}

// MARK: - Hashable
extension ItemModel: Hashable { }

struct TextConfiguration: Hashable {
	var text: String
	var style: TextStyle
	var colorToken: ColorToken
	var strikethrough: Bool
}

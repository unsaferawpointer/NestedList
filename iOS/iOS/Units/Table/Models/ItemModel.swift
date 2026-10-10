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
import CorePresentation

struct ItemModel {

	var uuid: UUID

	var compositeIcon: CompositeIconModel?

	var title: TextConfiguration

	var subtitle: TextConfiguration?

	var showsTrailingDisclosure: Bool
}

// MARK: - Initialization
extension ItemModel {

	init(presentation: ItemPresentation) {
		self.init(
			uuid: presentation.id,
			compositeIcon: presentation.compositeIcon,
			title: .init(
				text: presentation.title.value,
				style: presentation.title.style,
				colorToken: presentation.title.colorToken,
				strikethrough: presentation.title.strikethrough
			),
			subtitle: presentation.subtitle.map {
				.init(
					text: $0.value,
					style: $0.style,
					colorToken: $0.colorToken,
					strikethrough: $0.strikethrough
				)
			},
			showsTrailingDisclosure: presentation.showsTrailingDisclosure
		)
	}
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
			compositeIcon: compositeIcon,
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

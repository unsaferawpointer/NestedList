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
}

// MARK: - CellModel
extension ItemModel: CellModel {

	var selectionConfiguration: UIListContentConfiguration {
		var result = configuration
		result.image = nil
		return result
	}

	var configuration: UIListContentConfiguration {
		let configuration = {
			var configuration = UIListContentConfiguration.cell()
			let image: UIImage? = {
				if let iconConfiguration = icon {
					let symbolConfiguration = iconConfiguration.appearence.configuration
					return iconConfiguration.name?.uiImage.applyingSymbolConfiguration(symbolConfiguration)
				} else {
					return nil
				}
			}()
			configuration.image = image

			if let iconConfiguration = icon {
				configuration.imageProperties.tintColor = iconConfiguration.appearence.tint
			}

			configuration.attributedText = .init(
				string: title.text,
				textColor: title.colorToken.value,
				strikethrough: title.strikethrough
			)

			configuration.textProperties.font = .preferredFont(forTextStyle: title.style)

			if let subtitleConfiguration = subtitle {
				configuration.secondaryTextProperties.font = .preferredFont(forTextStyle: subtitleConfiguration.style)
				configuration.secondaryTextProperties.color = subtitleConfiguration.colorToken.value
				configuration.secondaryText = subtitleConfiguration.text
			} else {
				configuration.secondaryText = nil
				configuration.secondaryText = nil
			}

			configuration.secondaryText = subtitle?.text

			return configuration
		}()

		return configuration
	}

	typealias Cell = ItemCell

	func contentIsEquals(to other: ItemModel) -> Bool {
		return other.configuration == configuration
	}
}

// MARK: - Identifiable
extension ItemModel: Identifiable {

	var id: UUID {
		uuid
	}
}

// MARK: - IdentifiableValue
extension ItemModel: IdentifiableValue {

	mutating func generateId() {
		uuid = UUID()
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

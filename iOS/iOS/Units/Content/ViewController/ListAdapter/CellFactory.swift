//
//  CellFactory.swift
//  iOS
//
//  Created by Anton Cherkasov on 28.04.2025.
//

import UIKit

final class CellFactory {

}

extension CellFactory {

	static func updateCell(_ cell: ItemCell, with configuration: RowConfiguration) {

		let iconName = configuration.isExpanded ? "chevron.down" : "chevron.right"
		let image = UIImage(systemName: iconName)

		cell.accessoryView = !configuration.isLeaf ? UIImageView(image: image) : nil

		cell.indentationLevel = configuration.level
		cell.validateIndent()
	}

	static func updateCell(
		_ cell: UITableViewCell,
		with model: ItemModel,
		editingMode: EditingMode?,
		in tableView: UITableView?
	) {
		let configuration = {
			var configuration = UIListContentConfiguration.cell()
			let image: UIImage? = {
				if let iconConfiguration = model.icon {
					let symbolConfiguration = iconConfiguration.appearence.configuration
					return iconConfiguration.name?.uiImage.applyingSymbolConfiguration(symbolConfiguration)
				} else {
					return nil
				}
			}()
			configuration.image = (tableView?.isEditing ?? false) && editingMode == .selection
				? nil
				: image

			if let iconConfiguration = model.icon {
				configuration.imageProperties.tintColor = iconConfiguration.appearence.tint
			}

			configuration.attributedText = .init(
				string: model.title.text,
				textColor: model.title.colorToken.value,
				strikethrough: model.title.strikethrough
			)

			configuration.textProperties.font = .preferredFont(forTextStyle: model.title.style)

			if let subtitleConfiguration = model.subtitle {
				configuration.secondaryTextProperties.font = .preferredFont(forTextStyle: subtitleConfiguration.style)
				configuration.secondaryTextProperties.color = subtitleConfiguration.colorToken.value
				configuration.secondaryText = subtitleConfiguration.text
			} else {
				configuration.secondaryText = nil
				configuration.secondaryText = nil
			}

			configuration.secondaryText = model.subtitle?.text

			return configuration
		}()

		cell.contentConfiguration = configuration
	}
}

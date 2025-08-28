//
//  CellFactory.swift
//  iOS
//
//  Created by Anton Cherkasov on 28.04.2025.
//

import UIKit
import DesignSystem

final class CellFactory {

}

extension CellFactory {

	static func makeCell<C: ListCell>(with type: C.Type, in table: UITableView, at indexPath: IndexPath) -> C {
		let identifier = C.reuseIdentifier
		guard let cell = table.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? C else {
			fatalError("Invalid cell type")
		}
		cell.indentationWidth = 24
		cell.layoutMargins.left = 32
		cell.layoutMargins.right = 32
		return cell
	}

	static func updateCell<C: ListCell>(
		_ cell: C,
		with model: C.Model,
		in table: UITableView,
		editingMode: EditingMode?
	) {
		cell.contentConfiguration = table.isEditing && editingMode == .selection
			? model.selectionConfiguration
			: model.configuration
	}

	static func updateCell(_ cell: any ListCell, with configuration: RowConfiguration) {

		let iconName = configuration.isExpanded ? "chevron.down" : "chevron.right"
		let image = UIImage(systemName: iconName)?.withTintColor(.label)

		let imageView = !configuration.isLeaf ? UIImageView(image: image) : nil
		if #available(iOS 26.0, *) {
			imageView?.tintColor = .label
		}

		cell.accessoryView = imageView

		cell.indentationLevel = configuration.level
		cell.validateIndent()
	}
}

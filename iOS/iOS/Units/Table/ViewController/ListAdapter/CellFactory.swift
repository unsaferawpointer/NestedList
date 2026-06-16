//
//  CellFactory.swift
//  iOS
//
//  Created by Anton Cherkasov on 28.04.2025.
//

import UIKit
import DesignSystem

final class CellFactory { }

extension CellFactory {

	static func makeCell<C: ListCell>(
		with type: C.Type,
		in table: UITableView,
		at indexPath: IndexPath,
		for model: C.Model,
		row: RowConfiguration
	) -> C {
		let identifier = C.reuseIdentifier
		guard let cell = table.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? C else {
			fatalError("Invalid cell type")
		}

		cell.contentConfiguration = ItemContentConfiguration(
			id: model.id,
			row: row,
			content: model.configuration,
			showsTrailingDisclosure: model.showsTrailingDisclosure
		)
		return cell
	}

	static func updateCell<C: ListCell>(
		_ cell: C,
		with model: C.Model,
		row: RowConfiguration,
		in table: UITableView,
		editingMode: EditingMode?
	) {

		let content = table.isEditing && editingMode == .selection
			? model.selectionConfiguration
			: model.configuration

		cell.contentConfiguration = ItemContentConfiguration(
			id: model.id,
			row: row,
			content: content,
			showsTrailingDisclosure: model.showsTrailingDisclosure
		)
	}
}

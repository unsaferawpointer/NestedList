//
//  CellFactory.swift
//  iOS
//
//  Created by Anton Cherkasov on 28.04.2025.
//

import UIKit
import SwiftUI

import DesignSystem

final class CellFactory {

}

extension CellFactory {

	static func makeCell<C: ListCell>(with type: C.Type, in table: UITableView, at indexPath: IndexPath) -> C {
		let identifier = C.reuseIdentifier
		guard let cell = table.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? C else {
			fatalError("Invalid cell type")
		}
		return cell
	}

	static func updateCell<C: ListCell>(
		_ cell: C,
		with model: C.Model,
		in table: UITableView,
		editingMode: EditingMode?
	) {

		let content = table.isEditing && editingMode == .selection
			? model.selectionConfiguration
			: model.configuration

		if var configuration = cell.contentConfiguration as? ItemContentConfiguration {
			configuration.content = content
			cell.contentConfiguration = configuration
		} else {
			cell.contentConfiguration = ItemContentConfiguration(
				row: RowConfiguration(level: 0, isExpanded: false, isLeaf: true),
				content: content
			)
		}
	}

	static func updateCell(_ cell: any ListCell, with configuration: RowConfiguration) {

		guard var contentConfiguration = cell.contentConfiguration as? ItemContentConfiguration else {
			return
		}

		contentConfiguration.row = configuration
		cell.contentConfiguration = contentConfiguration
	}
}

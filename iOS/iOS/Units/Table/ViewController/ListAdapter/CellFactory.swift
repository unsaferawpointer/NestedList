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

		cell.contentConfiguration = UIHostingConfiguration {
			ItemView(model: .init(id: model.id as! UUID, title: model.configuration.text ?? "gfdgfd", textStyle: .headline, icon: .book(filled: false)))
		}

//		cell.contentConfiguration = table.isEditing && editingMode == .selection
//			? model.selectionConfiguration
//			: model.configuration
	}

	static func updateCell(_ cell: any ListCell, with configuration: RowConfiguration) {

		if let imageView = cell.accessoryView as? UIImageView {
			if configuration.isLeaf {
				cell.accessoryView = nil
			} else {
				UIView.animate(withDuration: 0.3) {
					imageView.transform = configuration.isExpanded ? .init(rotationAngle: .pi / 2) : .identity
				}
			}
		} else {
			if !configuration.isLeaf {
				let image = UIImage(systemName: "chevron.right")?
					.withConfiguration(UIImage.SymbolConfiguration(scale: .small))
				let imageView = UIImageView(image: image)
				imageView.contentMode = .center
				if #available(iOS 26.0, *) {
					imageView.tintColor = .label
				}
				imageView.transform = configuration.isExpanded ? .init(rotationAngle: .pi / 2) : .identity
				cell.accessoryView = imageView
			}
		}

		cell.indentationLevel = configuration.level
		cell.validateIndent()
	}
}

//
//  BottomToolbarFactory.swift
//  iOS
//
//  Created by Anton Cherkasov on 17.03.2025.
//

import Foundation

protocol ToolbarFactoryProtocol {
	func build(editingMode: EditingMode?, selectedCount: Int) -> ToolbarModel
}

final class ToolbarFactory { }

// MARK: - BottomToolbarFactoryProtocol
extension ToolbarFactory: ToolbarFactoryProtocol {

	func build(editingMode: EditingMode?, selectedCount: Int) -> ToolbarModel {

		let top = buildTop(editingMode: editingMode)
		let bottom = buildBottom(editingMode: editingMode, selectedCount: selectedCount)

		return ToolbarModel(top: top, bottom: bottom)
	}
}

// MARK: - Helpers
extension ToolbarFactory {

	func buildTop(editingMode: EditingMode?) -> [ToolbarModel.Item] {
		guard editingMode == nil else {
			return [.init(id: .done)]
		}

		return [.init(id: .more)]
	}

	func buildBottom(editingMode: EditingMode?, selectedCount: Int) -> [ToolbarModel.Item] {

		let isEmpty = selectedCount == 0

		let statusTitle = String(localized: "\(selectedCount)-toolbar-status", table: "UnitLocalizable")

		return switch editingMode {
		case .selection:
			[
				.init(id: .markAsComplete, isEnabled: !isEmpty),
				.init(id: .flexibleSpace, isEnabled: !isEmpty),
				.init(id: .status(title: statusTitle), isEnabled: true),
				.init(id: .flexibleSpace, isEnabled: !isEmpty),
				.init(id: .delete, isEnabled: !isEmpty)
			]
		case .reordering:
			[]
		case nil:
			[.init(id: .flexibleSpace), .init(id: .createNew)]
		}
	}
}

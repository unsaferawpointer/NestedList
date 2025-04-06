//
//  BottomToolbarFactory.swift
//  iOS
//
//  Created by Anton Cherkasov on 17.03.2025.
//

import Foundation
import DesignSystem

protocol ToolbarFactoryProtocol {
	func build(editingMode: EditingMode?, selectedCount: Int) -> ToolbarModel
}

final class ToolbarFactory {

	var localization: ToolbarLocalizationProtocol = ToolbarLocalization()
}

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

	func buildTop(editingMode: EditingMode?) -> [ToolbarItem] {
		guard editingMode == nil else {
			return [.init(id: ElementIdentifier.done.rawValue, title: localization.doneItemTitle)]
		}

		return [
			.init(
				id: "more",
				title: "",
				icon: .systemName("ellipsis.circle"),
				content: .menu(
					items:
						[
							.init(
								id: ElementIdentifier.select.rawValue,
								title: localization.selectItemTitle,
								icon: .systemName("checkmark.circle"),
								content: .item(state: .off, attributes: [])
							),
							.init(
								id: ElementIdentifier.reorder.rawValue,
								title: localization.reorderItemTitle,
								icon: .systemName("line.3.horizontal"),
								content: .item(state: .off, attributes: [])
							),
							.init(
								id: ElementIdentifier.settings.rawValue,
								title: localization.settingsItemTitle,
								icon: .systemName("slider.horizontal.2.square"),
								content: .item(state: .off, attributes: [])
							)
						]
				)
			)
		]
	}

	func buildBottom(editingMode: EditingMode?, selectedCount: Int) -> [ToolbarItem] {

		let isEmpty = selectedCount == 0

		let statusTitle = String(localized: "\(selectedCount)-toolbar-status", table: "UnitLocalizable")

		return switch editingMode {
		case .selection:
			[
				.init(id: ElementIdentifier.completed.rawValue, title: "", icon: .systemName("checkmark"), isEnabled: !isEmpty),
				.init(id: "", title: "", content: .flexible),
				.init(id: "", title: "", content: .status(text: statusTitle)),
				.init(id: "", title: "", content: .flexible),
				.init(id: ElementIdentifier.delete.rawValue, title: "", icon: .systemName("trash"), isEnabled: !isEmpty)
			]
		case .reordering:
			[]
		case nil:
			[
				.init(id: "", title: "", content: .flexible),
				.init(id: ElementIdentifier.new.rawValue, title: "", icon: .systemName("plus"))
			]
		}
	}
}

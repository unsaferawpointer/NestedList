//
//  BottomToolbarFactory.swift
//  iOS
//
//  Created by Anton Cherkasov on 17.03.2025.
//

import Foundation
import DesignSystem

protocol ToolbarFactoryProtocol {
	func build(editingMode: EditingMode?, selectedCount: Int, isCompleted: Bool?, isMarked: Bool?, isSection: Bool?) -> ToolbarModel
}

final class ToolbarFactory {

	var localization: ToolbarLocalizationProtocol = ToolbarLocalization()
}

// MARK: - BottomToolbarFactoryProtocol
extension ToolbarFactory: ToolbarFactoryProtocol {

	func build(editingMode: EditingMode?, selectedCount: Int, isCompleted: Bool?, isMarked: Bool?, isSection: Bool?) -> ToolbarModel {

		let top = buildTop(editingMode: editingMode)
		let bottom = buildBottom(
			editingMode: editingMode,
			selectedCount: selectedCount,
			isCompleted: isCompleted,
			isMarked: isMarked,
			isSection: isSection
		)

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

	func buildBottom(editingMode: EditingMode?, selectedCount: Int, isCompleted: Bool?, isMarked: Bool?, isSection: Bool?) -> [ToolbarItem] {

		let isEmpty = selectedCount == 0

		let statusTitle = String(localized: "\(selectedCount)-toolbar-status", table: "UnitLocalizable")

		let items: [MenuElement] =
		[
			.init(
				id: "",
				content: .menu(
					options: [.inline],
					size: .medium,
					items:
						[
							.init(
								id: ElementIdentifier.cut.rawValue,
								title: localization.cutItemTitle, icon: .systemName("scissors"),
								content: .item(state: .off, attributes: [])
							),
							.init(
								id: ElementIdentifier.copy.rawValue,
								title: localization.copyItemTitle,
								icon: .systemName("document.on.document"),
								content: .item(state: .off, attributes: [])
							),
							.init(
								id: ElementIdentifier.paste.rawValue,
								title: localization.pasteItemTitle,
								icon: .systemName("document.on.clipboard"),
								content: .item(state: .off, attributes: [])
							)
						]
				)
			),
			.init(
				id: ElementIdentifier.completed.rawValue,
				title: localization.strikethroughItemTitle,
				content: .item(state: isCompleted.state, attributes: [])
			),
			.init(
				id: ElementIdentifier.marked.rawValue,
				title: localization.markedItemTitle,
				content: .item(state: isMarked.state, attributes: [])
			),
			.init(
				id: ElementIdentifier.style.rawValue,
				title: localization.sectionItemTitle,
				content: .item(state: isSection.state, attributes: [])
			),
			.init(
				id: "",
				content: .menu(
					options: .inline,
					size: .large,
					items:
						[
							.init(
								id: ElementIdentifier.delete.rawValue,
								title: localization.deleteItemTitle,
								icon: .systemName("trash"),
								content: .item(state: .off, attributes: [.destructive])
							)
						]
				)
			)
		]

		return switch editingMode {
		case .selection:
			[
				.init(id: ElementIdentifier.completed.rawValue, title: "", icon: .systemName("checkmark"), isEnabled: !isEmpty),
				.init(id: "", title: "", content: .flexible),
				.init(id: "", title: "", content: .status(text: statusTitle)),
				.init(id: "", title: "", content: .flexible),
				.init(id: ElementIdentifier.delete.rawValue, title: "", icon: .systemName("ellipsis.circle"), content: .menu(items: items), isEnabled: !isEmpty)
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

fileprivate extension Optional<Bool> {

	var state: ControlState {
		switch self {
		case .none:					.mixed
		case .some(let wrapped):	wrapped ? .on : .off
		}
	}
}

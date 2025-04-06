//
//  MenuFactory.swift
//  iOS
//
//  Created by Anton Cherkasov on 06.04.2025.
//

import DesignSystem

final class MenuFactory {

	var localization: MenuLocalizationProtocol = MenuLocalization()
}

// MARK: - Public interface
extension MenuFactory {

	func build(isCompleted: Bool?, isMarked: Bool?, isSection: Bool?) -> [MenuElement] {
		return
		[
			.init(
				id: "",
				content: .menu(
					options: [.inline],
					size: .medium,
					items:
						[
							buildItem(id: .cut, title: localization.cutItemTitle, iconName: "scissors"),
							buildItem(id: .copy, title: localization.copyItemTitle, iconName: "document.on.document"),
							buildItem(id: .paste, title: localization.pasteItemTitle, iconName: "document.on.clipboard")
						]
				)
			),
			buildItem(id: .edit, title: localization.editItemTitle, iconName: "pencil"),
			buildItem(id: .new, title: localization.newItemTitle, iconName: "plus"),
			.init(
				id: "",
				content: .menu(
					options: .inline,
					size: .automatic,
					items:
						[
							buildItem(id: .completed, title: localization.completedItemTitle, state: isCompleted.state),
							buildItem(id: .marked, title: localization.markedItemTitle, state: isMarked.state),
							buildItem(id: .style, title: localization.sectionItemTitle, state: isSection.state)
						]
				)
			),
			buildItem(id: .delete, title: localization.deleteItemTitle, iconName: "trash", attributes: [.destructive])
		]
	}
}

// MARK: - Helpers
private extension MenuFactory {

	func buildItem(
		id: ElementIdentifier,
		title: String,
		iconName: String = "",
		state: ControlState = .off,
		attributes: MenuElement.Attributes = []
	) -> MenuElement {
		return MenuElement(
			id: id.rawValue,
			title: title,
			icon: .systemName(iconName),
			content: .item(state: state, attributes: attributes)
		)
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

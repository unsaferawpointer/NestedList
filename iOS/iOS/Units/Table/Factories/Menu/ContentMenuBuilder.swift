//
//  ContentMenuBuilder.swift
//  iOS
//
//  Created by Anton Cherkasov on 07.07.2026.
//

import UIKit

@MainActor protocol ContentMenuDelegate<ID>: AnyObject {
	associatedtype ID: Hashable
	func userDidTapMenu(with id: ContentMenuIdentifier, selection: [ID]?)
}

final class ContentMenuBuilder<ID: Hashable> {
	private let localization: MenuLocalizationProtocol = MenuLocalization()
}

extension ContentMenuBuilder {

	func build(
		with selection: [ID]?,
		configuration: ContentMenuConfiguration,
		delegate: (any ContentMenuDelegate<ID>)?
	) -> [UIMenuElement] {
		[
			UIMenu(
				identifier: .init("buffer"),
				options: [.displayInline],
				preferredElementSize: .medium,
				children:
					[
						UIAction(
							title: localization.cutItemTitle,
							image: UIImage(systemName: "scissors"),
							identifier: .init(ElementIdentifier.cut.rawValue),
							handler: { _ in
								delegate?.userDidTapMenu(
									with: .cutItems,
									selection: selection
								)
							}
						),
						UIAction(
							title: localization.copyItemTitle,
							image: UIImage(systemName: "doc.on.doc"),
							identifier: .init(ElementIdentifier.copy.rawValue),
							handler: { _ in
								delegate?.userDidTapMenu(
									with: .copyItems,
									selection: selection
								)
							}
						),
						UIAction(
							title: localization.pasteItemTitle,
							image: UIImage(systemName: "doc.on.clipboard"),
							identifier: .init(ElementIdentifier.paste.rawValue),
							handler: { _ in
								delegate?.userDidTapMenu(
									with: .paste,
									selection: selection
								)
							}
						)
					]
			),
			UIMenu(
				identifier: .init("editor"),
				options: [.displayInline],
				preferredElementSize: .automatic,
				children:
					[
						UIAction(
							title: localization.strikethroughItemTitle,
							identifier: .init(ElementIdentifier.strikethrough.rawValue),
							state: configuration[ElementIdentifier.strikethrough.rawValue].state,
							handler: { _ in
								delegate?.userDidTapMenu(
									with: .toggleStrikethrough,
									selection: selection
								)
							}
						),
						UIAction(
							title: localization.hideSubitemsItemTitle,
							identifier: .init(ElementIdentifier.hideSubitems.rawValue),
							state: configuration[ElementIdentifier.hideSubitems.rawValue].state,
							handler: { _ in
								delegate?.userDidTapMenu(
									with: .toggleSubitemsVisibility,
									selection: selection
								)
							}
						)
					]
			),
			UIAction(
				title: localization.editItemTitle,
				image: UIImage(systemName: "pencil"),
				identifier: .init(ElementIdentifier.edit.rawValue),
				handler: { _ in
					delegate?.userDidTapMenu(
						with: .editItem,
						selection: selection
					)
				}
			),
			UIAction(
				title: localization.newItemTitle,
				image: UIImage(systemName: "plus"),
				identifier: .init(ElementIdentifier.new.rawValue),
				handler: { _ in
					delegate?.userDidTapMenu(
						with: .newItem,
						selection: selection
					)
				}
			),
			UIMenu(
				title: localization.appearanceMenuTitle,
				image: UIImage(systemName: "slider.horizontal.below.square.filled.and.square"),
				identifier: .init("appearance-menu"),
				preferredElementSize: .automatic,
				children:
					[
						UIAction(
							title: localization.iconItemTitle,
							image: UIImage(systemName: "photo"),
							identifier: .init(ElementIdentifier.icon.rawValue),
							handler: { _ in
								delegate?.userDidTapMenu(
									with: .changeIcon,
									selection: selection
								)
							}
						),
						UIAction(
							title: localization.colorItemTitle,
							image: UIImage(systemName: "paintpalette"),
							identifier: .init(ElementIdentifier.color.rawValue),
							handler: { _ in
								delegate?.userDidTapMenu(
									with: .changeColor,
									selection: selection
								)
							}
						)
					]
			),
			UIMenu(
				identifier: .init("move-reorder-menu"),
				options: [.displayInline],
				preferredElementSize: .automatic,
				children:
					[
						UIAction(
							title: localization.moveItemTitle,
							image: UIImage(systemName: "arrow.left.arrow.right"),
							identifier: .init(ElementIdentifier.move.rawValue),
							handler: { _ in
								delegate?.userDidTapMenu(
									with: .moveItems,
									selection: selection
								)
							}
						),
						UIAction(
							title: localization.reorderItemTitle,
							image: UIImage(systemName: "arrow.up.arrow.down"),
							identifier: .init(ElementIdentifier.specialReorder.rawValue),
							handler: { _ in
								delegate?.userDidTapMenu(
									with: .reorderItems,
									selection: selection
								)
							}
						)
					]
			),
			UIAction(
				title: localization.deleteItemTitle,
				image: UIImage(systemName: "trash"),
				identifier: .init(ElementIdentifier.delete.rawValue),
				attributes: [.destructive],
				handler: { _ in
					delegate?.userDidTapMenu(
						with: .deleteItems,
						selection: selection
					)
				}
			)
		]
	}
}

fileprivate extension Optional<Bool> {

	var state: UIMenuElement.State {
		switch self {
		case .none:					.mixed
		case .some(let wrapped):	wrapped ? .on : .off
		}
	}
}

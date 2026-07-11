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
						buildAction(
							title: localization.cutItemTitle,
							icon: "scissors",
							identifier: .cutItems
						) {
							delegate?.userDidTapMenu(
								with: .cutItems,
								selection: selection
							)
						},
						buildAction(
							title: localization.copyItemTitle,
							icon: "doc.on.doc",
							identifier: .copyItems
						) {
							delegate?.userDidTapMenu(
								with: .copyItems,
								selection: selection
							)
						},
						buildAction(
							title: localization.pasteItemTitle,
							icon: "doc.on.clipboard",
							identifier: .paste
						) {
							delegate?.userDidTapMenu(
								with: .paste,
								selection: selection
							)
						}
					]
			),
			UIMenu(
				identifier: .init("editor"),
				options: [.displayInline],
				preferredElementSize: .automatic,
				children:
					[
						buildAction(
							title: localization.strikethroughItemTitle,
							identifier: .toggleStrikethrough,
							state: configuration[ContentMenuIdentifier.toggleStrikethrough.rawValue].state
						) {
							delegate?.userDidTapMenu(
								with: .toggleStrikethrough,
								selection: selection
							)
						},
						buildAction(
							title: localization.hideSubitemsItemTitle,
							identifier: .toggleSubitemsVisibility,
							state: configuration[ContentMenuIdentifier.toggleSubitemsVisibility.rawValue].state
						) {
							delegate?.userDidTapMenu(
								with: .toggleSubitemsVisibility,
								selection: selection
							)
						}
					]
			),
			buildAction(
				title: localization.editItemTitle,
				icon: "pencil",
				identifier: .editItem
			) {
				delegate?.userDidTapMenu(
					with: .editItem,
					selection: selection
				)
			},
			buildAction(
				title: localization.newItemTitle,
				icon: "plus",
				identifier: .newItem
			) {
				delegate?.userDidTapMenu(
					with: .newItem,
					selection: selection
				)
			},
			UIMenu(
				title: localization.appearanceMenuTitle,
				image: UIImage(systemName: "slider.horizontal.below.square.filled.and.square"),
				identifier: .init("appearance-menu"),
				preferredElementSize: .automatic,
				children:
					[
						buildAction(
							title: localization.iconItemTitle,
							icon: "photo",
							identifier: .changeIcon
						) {
							delegate?.userDidTapMenu(
								with: .changeIcon,
								selection: selection
							)
						},
						buildAction(
							title: localization.colorItemTitle,
							icon: "paintpalette",
							identifier: .changeColor
						) {
							delegate?.userDidTapMenu(
								with: .changeColor,
								selection: selection
							)
						}
					]
			),
			UIMenu(
				identifier: .init("move-reorder-menu"),
				options: [.displayInline],
				preferredElementSize: .automatic,
				children:
					[
						buildAction(
							title: localization.moveItemTitle,
							icon: "arrow.left.arrow.right",
							identifier: .moveItems
						) {
							delegate?.userDidTapMenu(
								with: .moveItems,
								selection: selection
							)
						},
						buildAction(
							title: localization.reorderItemTitle,
							icon: "arrow.up.arrow.down",
							identifier: .reorderItems
						) {
							delegate?.userDidTapMenu(
								with: .reorderItems,
								selection: selection
							)
						}
					]
			),
			buildAction(
				title: localization.deleteItemTitle,
				icon: "trash",
				identifier: .deleteItems,
				attributes: [.destructive]
			) {
				delegate?.userDidTapMenu(
					with: .deleteItems,
					selection: selection
				)
			}
		]
	}
}

// MARK: - Helpers
private extension ContentMenuBuilder {

	func buildAction(
		title: String,
		icon: String? = nil,
		identifier: ContentMenuIdentifier,
		attributes: UIMenuElement.Attributes = [],
		state: UIMenuElement.State = .off,
		handler: @MainActor @escaping () -> Void
	) -> UIAction {
		UIAction(
			title: title,
			image: icon.flatMap { UIImage(systemName: $0) },
			identifier: .init(identifier.rawValue),
			attributes: attributes,
			state: state,
			handler: { _ in
				Task { @MainActor in
					handler()
				}
			}
		)
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

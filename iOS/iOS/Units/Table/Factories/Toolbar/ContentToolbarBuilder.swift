//
//  ContentToolbarBuilder.swift
//  iOS
//
//  Created by Anton Cherkasov on 08.07.2026.
//

import UIKit

@MainActor protocol ContentToolbarDelegate<ID>: AnyObject {
	associatedtype ID: Hashable
	func userDidTapToolbar(with id: ContentToolbarIdentifier, selection: [ID]?)
}

final class ContentToolbarBuilder<ID: Hashable> {
	private let localization: ToolbarLocalizationProtocol = ToolbarLocalization()
}

// MARK: - Public interface
extension ContentToolbarBuilder {

	func build(
		configuration: ContentToolbarConfiguration<ID>,
		delegate: (any ContentToolbarDelegate<ID>)?
	) -> (top: [UIBarButtonItem], bottom: [UIBarButtonItem], showUndoGroup: Bool) {
		let top = buildTop(
			editingMode: configuration.editingMode,
			selection: configuration.selection,
			delegate: delegate
		)
		let bottom = buildBottom(
			editingMode: configuration.editingMode,
			selection: configuration.selection,
			isCompleted: configuration.isCompleted,
			isSubitemsHidden: configuration.isSubitemsHidden,
			delegate: delegate
		)

		return (top, bottom, configuration.showUndoGroup)
	}
}

// MARK: - Private methods
private extension ContentToolbarBuilder {

	func buildTop(
		editingMode: EditingMode?,
		selection: [ID],
		delegate: (any ContentToolbarDelegate<ID>)?
	) -> [UIBarButtonItem] {
		guard editingMode == nil else {
			return [
				barButton(
					identifier: .done,
					title: localization.doneItemTitle,
					selection: selection,
					delegate: delegate,
					isPrimaryAction: true
				)
			]
		}

		return [
			barButton(
				identifier: .more,
				image: "ellipsis",
				menu: UIMenu(
					children: [
						UIMenu(
							identifier: .init("mode"),
							options: [.displayInline],
							preferredElementSize: .large,
							children: [
								action(
									identifier: .selectionMode,
									title: localization.selectItemTitle,
									image: "checkmark.circle",
									selection: selection,
									delegate: delegate
								),
								action(
									identifier: .reorderingMode,
									title: localization.reorderItemTitle,
									image: "line.3.horizontal",
									selection: selection,
									delegate: delegate
								)
							]
						),
						UIMenu(
							identifier: .init("outline"),
							options: [.displayInline],
							preferredElementSize: .large,
							children: [
								action(
									identifier: .expandAll,
									title: localization.expandAllItemTitle,
									selection: selection,
									delegate: delegate
								),
								action(
									identifier: .collapseAll,
									title: localization.collapseAllItemTitle,
									selection: selection,
									delegate: delegate
								)
							]
						),
						action(
							identifier: .settings,
							title: localization.settingsItemTitle,
							image: "slider.horizontal.2.square",
							selection: selection,
							delegate: delegate
						)
					]
				)
			)
		]
	}

	func buildBottom(
		editingMode: EditingMode?,
		selection: [ID],
		isCompleted: Bool?,
		isSubitemsHidden: Bool?,
		delegate: (any ContentToolbarDelegate<ID>)?
	) -> [UIBarButtonItem] {
		let isEmpty = selection.isEmpty
		let statusTitle = String(localized: "\(selection.count)-toolbar-status", table: "UnitLocalizable")

		return switch editingMode {
		case .selection:
				[
					barButton(
						identifier: .selectAll,
						title: localization.selectAllItemTitle,
						selection: selection,
						delegate: delegate
					),
					.flexibleSpace(),
					statusItem(text: statusTitle),
					.flexibleSpace(),
					barButton(
						identifier: .done,
						image: "ellipsis",
						selection: selection,
						delegate: delegate,
						menu: selectionMenu(
							selection: selection,
							isCompleted: isCompleted,
							isSubitemsHidden: isSubitemsHidden,
							delegate: delegate
						),
						isEnabled: !isEmpty
					)
				]
		case .reordering:
			[.flexibleSpace()]
		case nil:
			[
				.flexibleSpace(),
				barButton(
					identifier: .newItem,
					image: "plus",
					selection: selection,
					delegate: delegate
				)
			]
		}
	}

	func selectionMenu(
		selection: [ID],
		isCompleted: Bool?,
		isSubitemsHidden: Bool?,
		delegate: (any ContentToolbarDelegate<ID>)?
	) -> UIMenu {
		UIMenu(
			children: [
				UIMenu(
					identifier: .init("buffer"),
					options: [.displayInline],
					preferredElementSize: .medium,
					children: [
						action(
							identifier: .cutItems,
							title: localization.cutItemTitle,
							image: "scissors",
							selection: selection,
							delegate: delegate
						),
						action(
							identifier: .copyItems,
							title: localization.copyItemTitle,
							image: "doc.on.doc",
							selection: selection,
							delegate: delegate
						)
					]
				),
				UIMenu(
					identifier: .init("appearance-menu"),
					options: [.displayInline],
					preferredElementSize: .automatic,
					children: [
						action(
							identifier: .changeIcon,
							title: localization.iconItemTitle,
							image: "photo",
							selection: selection,
							delegate: delegate
						),
						action(
							identifier: .changeColor,
							title: localization.colorItemTitle,
							image: "paintpalette",
							selection: selection,
							delegate: delegate
						)
					]
				),
				UIMenu(
					identifier: .init("move-reorder-menu"),
					options: [.displayInline],
					preferredElementSize: .automatic,
					children: [
						action(
							identifier: .moveItems,
							title: localization.moveItemTitle,
							image: "arrow.left.arrow.right",
							selection: selection,
							delegate: delegate
						)
					]
				),
				action(
					identifier: .toggleStrikethrough,
					title: localization.strikethroughItemTitle,
					state: isCompleted.state,
					selection: selection,
					delegate: delegate
				),
				action(
					identifier: .toggleSubitemsVisibility,
					title: localization.hideSubitemsItemTitle,
					state: isSubitemsHidden.state,
					selection: selection,
					delegate: delegate
				),
				UIMenu(
					identifier: .init("destructive"),
					options: [.displayInline],
					preferredElementSize: .large,
					children: [
						action(
							identifier: .deleteItems,
							title: localization.deleteItemTitle,
							image: "trash",
							attributes: [.destructive],
							selection: selection,
							delegate: delegate
						)
					]
				)
			]
		)
	}

	func action(
		identifier: ContentToolbarIdentifier,
		title: String,
		image: String? = nil,
		attributes: UIMenuElement.Attributes = [],
		state: UIMenuElement.State = .off,
		selection: [ID],
		delegate: (any ContentToolbarDelegate<ID>)?
	) -> UIAction {
		UIAction(
			title: title,
			image: image.map(UIImage.init(systemName:)) ?? nil,
			identifier: .init(identifier.rawValue),
			attributes: attributes,
			state: state,
			handler: { _ in
				Task { @MainActor in
					delegate?.userDidTapToolbar(with: identifier, selection: selection)
				}
			}
		)
	}

	func barButton(
		identifier: ContentToolbarIdentifier,
		title: String = "",
		image: String? = nil,
		selection: [ID] = [],
		delegate: (any ContentToolbarDelegate<ID>)? = nil,
		menu: UIMenu? = nil,
		isEnabled: Bool = true,
		isPrimaryAction: Bool = false
	) -> UIBarButtonItem {
		let primaryAction: UIAction? = menu == nil
			? UIAction { _ in
				Task { @MainActor in
					delegate?.userDidTapToolbar(with: identifier, selection: selection)
				}
			}
			: nil

		let result = UIBarButtonItem(
			title: title,
			image: image.map(UIImage.init(systemName:)) ?? nil,
			primaryAction: primaryAction,
			menu: menu
		)
		if #available(iOS 26.0, *) {
			result.identifier = identifier.rawValue
			result.style = isPrimaryAction ? .prominent : .plain
		}
		result.isEnabled = isEnabled
		result.accessibilityIdentifier = identifier.rawValue
		return result
	}

	func statusItem(text: String) -> UIBarButtonItem {
		let label = UILabel()
		label.text = text
		label.font = UIFont.preferredFont(forTextStyle: .caption1)
		label.translatesAutoresizingMaskIntoConstraints = false
		label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
		label.setContentHuggingPriority(.defaultLow, for: .horizontal)

		let result = UIBarButtonItem(customView: label)
		if #available(iOS 26.0, *) {
			result.hidesSharedBackground = true
		}
		return result
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

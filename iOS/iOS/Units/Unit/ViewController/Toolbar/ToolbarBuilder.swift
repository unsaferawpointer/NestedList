//
//  ToolbarBuilder.swift
//  iOS
//
//  Created by Anton Cherkasov on 16.03.2025.
//

import UIKit

protocol ToolbarDelegate: AnyObject {
	func toolbarDidTapDone()
	func toolbarDidTapSelect()
	func toolbarDidTapReorder()
	func toolbarDidTapSettings()
	func toolbarDidTapDelete()
	func toolbarDidTapMarkAsComplete()
	func toolbarDidTapAdd()
}

final class ToolbarBuilder {

	weak var delegate: ToolbarDelegate?
}

extension ToolbarBuilder {

	func build(items: [ToolbarModel.Item]) -> [UIBarButtonItem]? {
		return items.map { item in
			let localItem = buildItem(for: item.id)
			localItem.isEnabled = item.isEnabled
			return localItem
		}
	}

	func buildItem(for id: ToolbarModel.Identifier) -> UIBarButtonItem {
		switch id {
		case .createNew:
			UIBarButtonItem(
				title: "Create New",
				image: .init(systemName: "plus"),
				target: self,
				action: #selector(toolbarDidTapAdd)
			)
		case .markAsComplete:
			UIBarButtonItem(
				title: "Complete",
				image: .init(systemName: "checkmark"),
				target: self,
				action: #selector(toolbarDidTapMarkAsComplete)
			)
		case .delete:
			UIBarButtonItem(
				title: "Delete",
				image: .init(systemName: "trash"),
				target: self,
				action: #selector(toolbarDidTapDelete)
			)
		case .flexibleSpace:
			.flexibleSpace()
		case .done:
			UIBarButtonItem(
				title: "Done",
				style: .done,
				target: self,
				action: #selector(toolbarDidTapDone)
			)
		case .more:
			buildMoreButton()
		case .status(title: let title):
			buildStatusItem(title: title)
		}
	}
}

// MARK: - Helpers
private extension ToolbarBuilder {

	func buildStatusItem(title: String) -> UIBarButtonItem {
		let label = UILabel()
		label.text = title
		return UIBarButtonItem(customView: label)
	}

	func buildMoreButton() -> UIBarButtonItem {

		let selectAction = UIAction(title: "Select", image: UIImage(systemName: "checkmark.circle")) { [weak self] _ in
			self?.delegate?.toolbarDidTapSelect()
		}

		let reorderAction = UIAction(title: "Reorder", image: UIImage(systemName: "line.3.horizontal")) { [weak self] _ in
			self?.delegate?.toolbarDidTapReorder()
		}

		let settingsAction = UIAction(title: "Settings", image: UIImage(systemName: "slider.horizontal.2.square")) { [weak self] _ in
			self?.delegate?.toolbarDidTapSettings()
		}

		let primarySubmenu = UIMenu(
			title: "",
			subtitle: "",
			image: nil,
			identifier: nil,
			options: .displayInline,
			preferredElementSize: .large,
			children: [selectAction, reorderAction]
		)

		let secondarySubmenu = UIMenu(
			title: "",
			subtitle: "",
			image: nil,
			identifier: nil,
			options: .displayInline,
			preferredElementSize: .large,
			children: [settingsAction]
		)

		// Основное меню
		let menu = UIMenu(title: "", children: [primarySubmenu, secondarySubmenu])

		let menuButton = UIBarButtonItem(
			image: UIImage(systemName: "ellipsis.circle"),
			menu: menu
		)

		return menuButton
	}
}

// MARK: - Actions
extension ToolbarBuilder {

	@objc
	func toolbarDidTapDone() {
		delegate?.toolbarDidTapDone()
	}

	@objc
	func toolbarDidTapMarkAsComplete() {
		delegate?.toolbarDidTapMarkAsComplete()
	}

	@objc
	func toolbarDidTapDelete() {
		delegate?.toolbarDidTapDelete()
	}

	@objc
	func toolbarDidTapAdd() {
		delegate?.toolbarDidTapAdd()
	}
}

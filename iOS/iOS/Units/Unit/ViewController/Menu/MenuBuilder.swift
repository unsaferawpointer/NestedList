//
//  MenuBuilder.swift
//  iOS
//
//  Created by Anton Cherkasov on 18.03.2025.
//

import UIKit
import CoreModule

protocol MenuDelegate<ID>: AnyObject {

	associatedtype ID

	func menuDidEdit(id: ID)
	func menuDidDelete(ids: [ID])
	func menuDidAdd(target: ID)
	func menuDidSetStatus(isDone: Bool, id: ID)
	func menuDidMark(isMarked: Bool, id: ID)
	func menuDidSetStyle(style: Item.Style, id: ID)
	func menuDidCut(ids: [ID])
	func menuDidPaste(target: ID)
	func menuDidCopy(ids: [ID])
}

final class MenuBuilder {

	weak var delegate: (any MenuDelegate<UUID>)?
}

extension MenuBuilder {

	func buildConfiguration(for model: ItemModel) -> UIContextMenuConfiguration {
		return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { suggestedActions in

			let editItem = UIAction(title: "Edit...", image: UIImage(systemName: "pencil")) { [weak self] action in
				self?.delegate?.menuDidEdit(id: model.id)
			}

			let editGroup = UIMenu(
				title: "", image: nil,
				identifier: nil,
				options: [.displayInline],
				preferredElementSize: .medium,
				children: [editItem]
			)
			editGroup.preferredElementSize = .large

			let newItem = UIAction(title: "New...", image: UIImage(systemName: "plus")) { [weak self] action in
				self?.delegate?.menuDidAdd(target: model.id)
			}

			let cutItem = UIAction(title: "Cut", image: UIImage(systemName: "scissors")) { [weak self] action in
				self?.delegate?.menuDidCut(ids: [model.id])
			}

			let copyItem = UIAction(title: "Copy", image: UIImage(systemName: "document.on.document")) { [weak self] action in
				self?.delegate?.menuDidCopy(ids: [model.id])
			}

			let pasteItem = UIAction(title: "Paste", image: UIImage(systemName: "document.on.clipboard")) { [weak self] action in
				self?.delegate?.menuDidPaste(target: model.id)
			}

			let groupItem = UIMenu(
				title: "", image: nil,
				identifier: nil,
				options: [.displayInline],
				preferredElementSize: .medium,
				children: [cutItem, copyItem, pasteItem]
			)

			let deleteItem = UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: .destructive) { [weak self] action in
				self?.delegate?.menuDidDelete(ids: [model.id])
			}

			let statusItem = UIAction(
				title: "Completed",
				image: nil
			) { [weak self] action in
				self?.delegate?.menuDidSetStatus(isDone: !model.status, id: model.id)
			}
			statusItem.state = model.status ? .on : .off

			let markItem = UIAction(
				title: "Marked",
				image: nil
			) { [weak self] action in
				self?.delegate?.menuDidMark(isMarked: !model.isMarked, id: model.id)
			}
			markItem.state = model.isMarked ? .on : .off

			let statusGroup = UIMenu(
				title: "",
				image: nil,
				identifier: nil,
				options: [.displayInline],
				preferredElementSize: .large,
				children: [statusItem, markItem]
			)

			let defaultStyleItem = UIAction(
				title: "Item",
				image: nil
			) { [weak self] action in
				self?.delegate?.menuDidSetStyle(style: .item, id: model.id)
			}

			let sectionStyleItem = UIAction(
				title: "Section",
				image: nil
			) { [weak self] action in
				self?.delegate?.menuDidSetStyle(style: .section, id: model.id)
			}

			let styleGroup = UIMenu(
				title: "Style",
				image: nil,
				identifier: nil,
				options: [],
				preferredElementSize: .large,
				children: [defaultStyleItem, sectionStyleItem]
			)

			let menu = UIMenu(title: "", children: [groupItem, newItem, editGroup, statusGroup, styleGroup, deleteItem])

			return menu
		}
	}
}

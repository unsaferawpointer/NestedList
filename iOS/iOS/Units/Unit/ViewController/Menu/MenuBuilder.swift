//
//  MenuBuilder.swift
//  iOS
//
//  Created by Anton Cherkasov on 18.03.2025.
//

import UIKit
import DesignSystem
import CoreModule

enum ElementIdentifier: String {
	case edit
	case new
	case cut
	case copy
	case paste
	case delete
	case completed
	case marked
	case style
}

final class MenuBuilder {

	weak var delegate: (any MenuDelegate<UUID>)?
}

extension MenuBuilder {

	func buildConfiguration(for model: ItemModel) -> UIContextMenuConfiguration {
		return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { suggestedActions in

			let editItem = UIAction(title: "Edit...", image: UIImage(systemName: "pencil")) { [weak self] action in
				self?.delegate?.menuDidSelect(item: ElementIdentifier.edit.rawValue, with: [model.id])
			}

			let editGroup = UIMenu(
				title: "", image: nil,
				identifier: nil,
				options: [.displayInline],
				preferredElementSize: .medium,
				children: [editItem]
			)
			editGroup.preferredElementSize = .large

			let new = UIAction(title: "New...", image: UIImage(systemName: "plus")) { [weak self] action in
				self?.delegate?.menuDidSelect(item: ElementIdentifier.new.rawValue, with: [model.id])
			}

			let cut = UIAction(title: "Cut", image: UIImage(systemName: "scissors")) { [weak self] action in
				self?.delegate?.menuDidSelect(item: ElementIdentifier.cut.rawValue, with: [model.id])
			}

			let copy = UIAction(title: "Copy", image: UIImage(systemName: "document.on.document")) { [weak self] action in
				self?.delegate?.menuDidSelect(item: ElementIdentifier.copy.rawValue, with: [model.id])
			}

			let paste = UIAction(title: "Paste", image: UIImage(systemName: "document.on.clipboard")) { [weak self] action in
				self?.delegate?.menuDidSelect(item: ElementIdentifier.paste.rawValue, with: [model.id])
			}

			let groupItem = UIMenu(
				title: "", image: nil,
				identifier: nil,
				options: [.displayInline],
				preferredElementSize: .medium,
				children: [cut, copy, paste]
			)

			let delete = UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: .destructive) { [weak self] action in
				self?.delegate?.menuDidSelect(item: ElementIdentifier.delete.rawValue, with: [model.id])
			}

			let statusItem = UIAction(
				title: "Completed",
				image: nil
			) { [weak self] action in
				self?.delegate?.menuDidSelect(item: ElementIdentifier.completed.rawValue, with: [model.id])
			}
			statusItem.state = model.status ? .on : .off

			let marked = UIAction(
				title: "Marked",
				image: nil
			) { [weak self] action in
				self?.delegate?.menuDidSelect(item: ElementIdentifier.marked.rawValue, with: [model.id])
			}
			marked.state = model.isMarked ? .on : .off

			let statusGroup = UIMenu(
				title: "",
				image: nil,
				identifier: nil,
				options: [.displayInline],
				preferredElementSize: .large,
				children: [statusItem, marked]
			)

			let style = UIAction(
				title: "Section",
				image: nil
			) { [weak self] action in
				self?.delegate?.menuDidSelect(item: ElementIdentifier.style.rawValue, with: [model.id])
			}
			style.state = model.isSection ? .on : .off

			let styleGroup = UIMenu(
				title: "",
				image: nil,
				identifier: nil,
				options: [.displayInline],
				preferredElementSize: .large,
				children: [style]
			)

			let menu = UIMenu(title: "", children: [groupItem, new, editGroup, statusGroup, styleGroup, delete])

			return menu
		}
	}
}

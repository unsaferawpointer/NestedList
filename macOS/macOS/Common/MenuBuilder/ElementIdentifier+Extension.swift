//
//  ElementIdentifier+Extension.swift
//  Nested List
//
//  Created by Anton Cherkasov on 12.04.2025.
//

import DesignSystem

extension ElementIdentifier {

	static let newItem: ElementIdentifier = .init(rawValue: "newItem-menu-item")

	static let completed: ElementIdentifier = .init(rawValue: "strikethrough-menu-item")

	static let note: ElementIdentifier = .init(rawValue: "note-menu-item")

	static let delete: ElementIdentifier = .init(rawValue: "delete-menu-item")

	static let cut: ElementIdentifier = .init(rawValue: "cut-menu-item")

	static let copy: ElementIdentifier = .init(rawValue: "copy-menu-item")

	static let paste: ElementIdentifier = .init(rawValue: "paste-menu-item")

	static let appearanceHeader: ElementIdentifier = .init(rawValue: "appearance-header-menu-item")

	static let icon: ElementIdentifier = .init(rawValue: "icon-menu-item")

	static let color: ElementIdentifier = .init(rawValue: "color-menu-item")

	static let noColor: ElementIdentifier = .init(rawValue: "no-color-menu-item")

	static let separator: ElementIdentifier = .init(rawValue: "separator-menu-item")

	static let edit: ElementIdentifier = .init(rawValue: "edit-menu-item")
}

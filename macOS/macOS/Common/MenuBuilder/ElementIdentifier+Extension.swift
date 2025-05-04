//
//  ElementIdentifier+Extension.swift
//  Nested List
//
//  Created by Anton Cherkasov on 12.04.2025.
//

import DesignSystem

extension ElementIdentifier {

	static let newItem: ElementIdentifier = .init(rawValue: "newItem-menu-item")

	static let completed: ElementIdentifier = .init(rawValue: "completed-menu-item")

	static let marked: ElementIdentifier = .init(rawValue: "marked-menu-item")

	static let note: ElementIdentifier = .init(rawValue: "note-menu-item")

	static let delete: ElementIdentifier = .init(rawValue: "delete-menu-item")

	static let cut: ElementIdentifier = .init(rawValue: "cut-menu-item")

	static let copy: ElementIdentifier = .init(rawValue: "copy-menu-item")

	static let paste: ElementIdentifier = .init(rawValue: "paste-menu-item")

	static let section: ElementIdentifier = .init(rawValue: "section-menu-item")

	static let noIcon: ElementIdentifier = .init(rawValue: "no-icon-menu-item")

	static let plainItem: ElementIdentifier = .init(rawValue: "plain-item-menu-item")
}

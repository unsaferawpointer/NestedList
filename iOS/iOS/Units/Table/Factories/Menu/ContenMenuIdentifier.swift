//
//  ContenMenuIdentifier.swift
//  iOS
//
//  Created by Anton Cherkasov on 09.07.2026.
//

enum ContentMenuIdentifier: String {

	case cutItems = "cut"
	case copyItems = "copy"
	case paste

	case editItem = "edit"
	case newItem = "new-item"

	case toggleStrikethrough = "completed-toggle"
	case toggleSubitemsVisibility = "hide-subitems-toggle"

	case changeIcon = "icon"
	case changeColor = "color"

	case moveItems = "move"
	case reorderItems = "reorder"

	case deleteItems = "delete"
}

// MARK: - Equatable
extension ContentMenuIdentifier: Equatable { }

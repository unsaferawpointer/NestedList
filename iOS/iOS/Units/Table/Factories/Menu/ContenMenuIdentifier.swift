//
//  ContenMenuIdentifier.swift
//  iOS
//
//  Created by Anton Cherkasov on 09.07.2026.
//

enum ContentMenuIdentifier: String {

	case cutItems
	case copyItems
	case paste

	case editItem
	case newItem

	case toggleStrikethrough
	case toggleSubitemsVisibility

	case changeIcon
	case changeColor

	case moveItems
	case reorderItems

	case deleteItems
}

// MARK: - Equatable
extension ContentMenuIdentifier: Equatable { }

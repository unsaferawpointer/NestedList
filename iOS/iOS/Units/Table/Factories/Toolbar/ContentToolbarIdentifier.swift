//
//  ContentToolbarIdentifier.swift
//  iOS
//
//  Created by Anton Cherkasov on 09.07.2026.
//

enum ContentToolbarIdentifier: String {

	case cutItems
	case copyItems

	case newItem

	case toggleStrikethrough
	case toggleSubitemsVisibility

	case changeIcon
	case changeColor

	case moveItems

	case deleteItems

	case done
	case settings
	case reorderingMode
	case selectionMode

	case selectAll
	case collapseAll
	case expandAll

	case more
}

// MARK: - Equatable
extension ContentToolbarIdentifier: Equatable { }

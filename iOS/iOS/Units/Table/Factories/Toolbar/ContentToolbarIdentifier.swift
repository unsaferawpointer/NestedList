//
//  ContentToolbarIdentifier.swift
//  iOS
//
//  Created by Anton Cherkasov on 09.07.2026.
//

enum ContentToolbarIdentifier: String {

	case cutItems = "cut"
	case copyItems = "copy"

	case newItem = "new-item"

	case toggleStrikethrough = "completed-toggle"
	case toggleSubitemsVisibility = "hide-subitems-toggle"

	case changeIcon = "icon"
	case changeColor = "color"

	case moveItems = "move"

	case deleteItems = "delete"

	case done
	case settings
	case reorderingMode = "reordering-mode"
	case selectionMode = "selection-mode"

	case selectAll = "select-all"
	case collapseAll = "collapse-all"
	case expandAll = "expand-all"

	case more
}

// MARK: - Equatable
extension ContentToolbarIdentifier: Equatable { }

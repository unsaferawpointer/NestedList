//
//  ContentMenuIdentifier.swift
//  CorePresentation
//
//  Created by Anton Cherkasov on 11.07.2026.
//

public enum ContentMenuIdentifier: String, Equatable {

	case cutItems = "cut"
	case copyItems = "copy"
	case paste = "paste"

	case editItem = "edit"
	case newItem = "new-item"

	case toggleStrikethrough = "completed-toggle"
	case toggleSubitemsVisibility = "hide-subitems-toggle"

	case changeIcon = "icon"
	case changeColor = "color"

	case deleteItems = "delete"

	#if os(iOS)
	case moveItems = "move"
	case reorderItems = "reorder"
	#endif

	#if os(macOS)
	case toggleNote = "note-toggle"
	case appearanceHeader = "appearance-header"
	case separator = "separator"
	#endif
}

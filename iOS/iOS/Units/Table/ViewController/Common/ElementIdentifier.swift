//
//  ElementIdentifier.swift
//  iOS
//
//  Created by Anton Cherkasov on 06.04.2025.
//

import Foundation

enum ElementIdentifier: String {
	case edit
	case new = "create-new-item"
	case move
	case specialReorder
	case cut
	case copy
	case paste
	case delete
	case strikethrough

	case icon
	case color

	case select
	case selectAll
	case reorder
	case settings
	case done

	case expandAll
	case collapseAll
}

//
//  ColumnsViewState.swift
//  macOS
//

import Foundation
import DesignSystem

/// The state rendered by the Columns unit.
enum ColumnsViewState {
	case placeholder(model: PlaceholderModel)
	case columns(ids: [UUID])
}

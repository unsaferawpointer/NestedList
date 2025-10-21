//
//  ColumnsViewState.swift
//  Nested List
//
//  Created by Anton Cherkasov on 30.08.2025.
//

import Foundation
import Hierarchy
import DesignSystem

enum ColumnsViewState {
	case placeholder(model: PlaceholderModel)
	case columns(ids: [UUID])
}

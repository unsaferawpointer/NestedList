//
//  ContentViewState.swift
//  Nested List
//
//  Created by Anton Cherkasov on 27.08.2025.
//

import Hierarchy
import DesignSystem

enum ContentViewState {
	case placeholder(model: PlaceholderModel)
	case list(snapshot: Snapshot<ItemModel>)
}

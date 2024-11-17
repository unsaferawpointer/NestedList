//
//  NSOutlineView+Extension.swift
//  DesignSystem
//
//  Created by Anton Cherkasov on 17.11.2024.
//

import Cocoa

extension NSOutlineView {

	func effectiveSelection() -> IndexSet {
		if clickedRow != -1 {
			if selectedRowIndexes.contains(clickedRow) {
				return selectedRowIndexes
			} else {
				return IndexSet(integer: clickedRow)
			}
		} else {
			return selectedRowIndexes
		}
	}
}

//
//  NSOutlineView+Extension.swift
//  DesignSystem
//
//  Created by Anton Cherkasov on 17.11.2024.
//

#if canImport(Cocoa)
import Cocoa
#endif

#if os(macOS)
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

	func scroll(to item: Any) {
		guard let row = row(for: item) else {
			return
		}

		NSAnimationContext.runAnimationGroup { context in
			context.allowsImplicitAnimation = true
			scrollRowToVisible(row)
		}
	}

	func select(_ item: Any) {
		guard let row = row(for: item) else {
			return
		}

		selectRowIndexes(.init(integer: row), byExtendingSelection: false)
	}

	func expand(_ items: [Any]?) {
		guard let items else {
			animator().expandItem(nil, expandChildren: true)
			return
		}

		NSAnimationContext.runAnimationGroup { context in
			for item in items {
				animator().expandItem(item)
			}
		}
	}
}

// MARK: - Helpers
fileprivate extension NSOutlineView {

	func row(for item: Any) -> Int? {
		let row = self.row(forItem: item)
		return row >= 0 ? row : nil
	}
}
#endif

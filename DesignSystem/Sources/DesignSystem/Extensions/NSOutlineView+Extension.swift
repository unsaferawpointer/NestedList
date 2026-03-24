//
//  NSOutlineView+Extension.swift
//  DesignSystem
//
//  Created by Anton Cherkasov on 17.11.2024.
//

#if canImport(Cocoa)
import Cocoa

public extension NSOutlineView {

	static var standart: NSOutlineView {
		let view = NSOutlineView()
		view.style = .inset
		view.rowSizeStyle = .large
		view.floatsGroupRows = false
		view.allowsMultipleSelection = true
		view.allowsColumnResizing = false
		view.usesAlternatingRowBackgroundColors = false
		view.autoresizesOutlineColumn = false
		view.usesAutomaticRowHeights = false
		view.indentationPerLevel = 16
		view.intercellSpacing = .init(width: 0, height: 0)
		view.backgroundColor = .clear
		return view
	}
}

extension NSOutlineView {

	func clickedItem<T>(with type: T.Type) -> T? {
		guard clickedRow != -1 else {
			return nil
		}
		return item(atRow: clickedRow) as? T
	}

	func effectiveSelection() -> IndexSet {
		guard clickedRow != -1 else {
			return selectedRowIndexes
		}
		return selectedRowIndexes.contains(clickedRow)
			? selectedRowIndexes
			: .init(integer: clickedRow)
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

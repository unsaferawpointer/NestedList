//
//  NSScrollView+Extension.swift
//  DesignSystem
//
//  Created by Anton Cherkasov on 20.03.2026.
//

#if canImport(Cocoa)
import Cocoa

public extension NSScrollView {

	static var standart: NSScrollView {
		let view = NSScrollView()
		view.borderType = .noBorder
		view.hasHorizontalScroller = false
		view.autohidesScrollers = true
		view.hasVerticalScroller = false
		view.automaticallyAdjustsContentInsets = true
		view.drawsBackground = true
		return view
	}
}
#endif

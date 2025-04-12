//
//  MenuSupportable.swift
//  macOS
//
//  Created by Anton Cherkasov on 17.11.2024.
//

import Cocoa
import DesignSystem

@objc
protocol MenuSupportable {
	func menuDidClickedItem(_ sender: NSMenuItem)
	func newItem(_ sender: NSMenuItem)
	func copy(_ sender: NSMenuItem)
	func paste(_ sender: NSMenuItem)
	func cut(_ sender: NSMenuItem)
}

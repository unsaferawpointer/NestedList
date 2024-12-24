//
//  MenuSupportable.swift
//  macOS
//
//  Created by Anton Cherkasov on 17.11.2024.
//

import Cocoa

@objc
protocol MenuSupportable {
	func newItem(_ sender: NSMenuItem)
	func deleteItem(_ sender: NSMenuItem)
	func toggleStatus(_ sender: NSMenuItem)
	func copy(_ sender: NSMenuItem)
	func paste(_ sender: NSMenuItem)
	func cut(_ sender: NSMenuItem)
	func setItemStyle(_ sender: NSMenuItem)
}

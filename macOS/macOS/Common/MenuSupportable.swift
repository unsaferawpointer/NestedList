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
}

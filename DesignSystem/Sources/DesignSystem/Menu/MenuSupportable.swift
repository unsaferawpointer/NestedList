//
//  MenuSupportable.swift
//  DesignSystem
//
//  Created by Anton Cherkasov on 15.08.2026.
//

#if canImport(AppKit)
import AppKit

@objc public protocol MenuSupportable {
	func menuItemClicked(_ sender: NSMenuItem)
}
#endif

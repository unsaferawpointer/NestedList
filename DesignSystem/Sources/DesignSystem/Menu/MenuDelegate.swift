//
//  MenuDelegate.swift
//  DesignSystem
//
//  Created by Anton Cherkasov on 12.04.2025.
//

#if os(macOS)
@MainActor public protocol MenuDelegate<ID>: AnyObject {

	associatedtype ID: Hashable

	func menuItemClicked(_ item: ID, source: MenuSource)
	func validateMenuItem(_ item: ID) -> Bool
	func stateForMenuItem(_ item: ID) -> ControlState
	func menuItems() -> [ID]
}
#endif

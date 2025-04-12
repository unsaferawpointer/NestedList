//
//  MenuDelegate.swift
//  DesignSystem
//
//  Created by Anton Cherkasov on 12.04.2025.
//

#if os(macOS)
public protocol MenuDelegate: AnyObject {
	func menuItemClicked(_ item: ElementIdentifier)
	func validateMenuItem(_ item: ElementIdentifier) -> Bool
	func stateForMenuItem(_ item: ElementIdentifier) -> ControlState
}
#endif

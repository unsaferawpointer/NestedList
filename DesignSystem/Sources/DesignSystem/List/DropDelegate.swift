//
//  DropDelegate.swift
//  DesignSystem
//
//  Created by Anton Cherkasov on 17.11.2024.
//

import Hierarchy

#if os(macOS)

public protocol DropDelegate<ID>: AnyObject {

	associatedtype ID

	func move(_ ids: [ID], to destination: Destination<ID>)
	func copy(_ ids: [ID], to destination: Destination<ID>)
	func validateMovement(_ ids: [ID], to destination: Destination<ID>) -> Bool
	func validateDrop(_ info: PasteboardInfo, to destination: Destination<ID>) -> Bool
	func drop(_ info: PasteboardInfo, to destination: Destination<ID>)
}
#endif

#if os(iOS)

public protocol DropDelegate<ID>: AnyObject {

	associatedtype ID

	func move(_ ids: [ID], to destination: Destination<ID>)
	func validateMovement(_ ids: [ID], to destination: Destination<ID>) -> Bool
}
#endif

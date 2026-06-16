//
//  DropDelegate.swift
//  DesignSystem
//
//  Created by Anton Cherkasov on 17.11.2024.
//

import Foundation
import Hierarchy

#if os(macOS)

@MainActor
public protocol DropDelegate<ID>: AnyObject {

	associatedtype ID

	func move(_ ids: [ID], to destination: Destination<ID>)
	func copy(_ ids: [ID], to destination: Destination<ID>)
	func validateMovement(_ ids: [ID], to destination: Destination<ID>) -> Bool
	func validateDrop(_ info: PasteboardInfo, to destination: Destination<ID>) -> Bool
	func drop(_ info: PasteboardInfo, to destination: Destination<ID>)
	func availableTypes() -> Set<String>
}
#endif

#if os(iOS)

@MainActor
public protocol DropDelegate<ID>: AnyObject {

	associatedtype ID

	func move(_ ids: [ID], to destination: Destination<ID>)
	func validateMovement(_ ids: [ID], to destination: Destination<ID>) -> Bool
	func dropItems(providers: [NSItemProvider], to destination: Destination<ID>)
	func provider(for id: ID) -> NSItemProvider?
	func availableTypes() -> [String]
}
#endif

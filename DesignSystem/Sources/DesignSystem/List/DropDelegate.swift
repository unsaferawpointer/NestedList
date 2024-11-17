//
//  DropDelegate.swift
//  DesignSystem
//
//  Created by Anton Cherkasov on 17.11.2024.
//

import Hierarchy

public protocol DropDelegate<ID>: AnyObject {

	associatedtype ID

	func move(_ ids: [ID], to destination: Destination<ID>)
	func validateMovement(_ ids: [ID], to destination: Destination<ID>) -> Bool
}

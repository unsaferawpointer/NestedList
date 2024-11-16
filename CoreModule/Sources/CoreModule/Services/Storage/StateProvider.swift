//
//  StateProvider.swift
//  CoreModule
//
//  Created by Anton Cherkasov on 16.11.2024.
//

import Foundation

public protocol StateProvider<State> {

	associatedtype State

	func modificate(_ block: (inout State) -> Void)

	func addObservation<O: AnyObject>(
		for object: O,
		handler: @escaping (O, State) -> Void
	)
}

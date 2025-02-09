//
//  StateProviderProtocol.swift
//  CoreModule
//
//  Created by Anton Cherkasov on 16.11.2024.
//

import Foundation

public protocol StateProviderProtocol<State>: AnyObject {

	associatedtype State

	var state: State { get set }

	func modificate(_ block: (inout State) -> Void)

	func addObservation<O: AnyObject>(
		for object: O,
		handler: @escaping (O, State) -> Void
	)
}

public final class StateProvider<State> {

	private var observations = [(State) -> Bool]()

	public var state: State {
		didSet {
			observations = observations.filter { $0(state) }
		}
	}

	// MARK: - Initialization

	public init(initialState: State) {
		self.state = initialState
	}
}

// MARK: - StateProviderProtocol
extension StateProvider: StateProviderProtocol {

	public func modificate(_ block: (inout State) -> Void) {
		block(&state)
	}
	
	public func addObservation<O: AnyObject>(
		for object: O,
		handler: @escaping (O, State) -> Void
	) {
		handler(object, state)

		observations.append { [weak object] value in
			guard let object = object else {
				return false
			}

			handler(object, value)
			return true
		}
	}
}

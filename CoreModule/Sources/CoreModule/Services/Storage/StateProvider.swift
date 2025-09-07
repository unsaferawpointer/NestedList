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
		handler: @escaping (State) -> Void
	)

	func removeObserver(_ object: AnyObject)
}

public final class StateProvider<State> {

	private var observations = [ObjectIdentifier: (State) -> Void]()

	public var state: State {
		didSet {
			observations.values.forEach {
				$0(state)
			}
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
		handler: @escaping (State) -> Void
	) {
		handler(state)

		observations[ObjectIdentifier(object)] = { value in
			handler(value)
		}
	}

	public func removeObserver(_ object: AnyObject) {
		observations[ObjectIdentifier(object)] = nil
	}
}

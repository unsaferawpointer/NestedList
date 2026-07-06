//
//  StateProviderMock.swift
//  iOSTests
//
//  Created by Anton Cherkasov on 06.07.2026.
//

import CoreModule

final class StateProviderMock<State> {

	var stubs = Stubs()
}

// MARK: - StateProviderProtocol
extension StateProviderMock: StateProviderProtocol {

	var state: State {
		get { stubs.state! }
		set { stubs.state = newValue }
	}

	func modificate(_ block: (inout State) -> Void) { }

	func addObservation<O: AnyObject>(for object: O, handler: @escaping (State) -> Void) { }

	func removeObserver(_ object: AnyObject) { }
}

// MARK: - Nested data structs
extension StateProviderMock {

	struct Stubs {
		var state: State?
	}
}

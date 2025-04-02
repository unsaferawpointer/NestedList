//
//  StateProviderMock.swift
//  macOSTests
//
//  Created by Anton Cherkasov on 12.03.2025.
//

import Foundation
import CoreModule

final class StateProviderMock<State> {
	private(set) var invocations: [Action] = []
	var stubs = Stubs()
}

// MARK: - StateProviderProtocol
extension StateProviderMock: StateProviderProtocol {

	var state: State {
		get {
			guard let stub = stubs.state else {
				fatalError("Configure stub")
			}
			return stub
		}
		set(newValue) {
			invocations.append(.setState(value: newValue))
		}
	}
	
	func modificate(_ block: (inout State) -> Void) {
		invocations.append(.modificate)
	}
	
	func addObservation<O>(for object: O, handler: @escaping (O, State) -> Void) where O : AnyObject {
		invocations.append(.addObservation)
	}
}

// MARK: - Nested data structs
extension StateProviderMock {

	enum Action {
		case setState(value: State)
		case modificate
		case addObservation
	}

	struct Stubs {
		var state: State?
	}
}

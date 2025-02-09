//
//  DocumentStorage.swift
//  CoreModule
//
//  Created by Anton Cherkasov on 16.11.2024.
//

import Foundation

public final class DocumentStorage<State: Codable> {

	private let contentProvider: any ContentProvider<State>

	private let stateProvider: any StateProviderProtocol<State>

	// MARK: - Undo Manager

	private(set) var undoManager: UndoManager?

	// MARK: - Initialization

	/// Basic initialization
	///
	/// - Parameters:
	///    - stateProvider: Document state provider
	///    - contentProvider: Document file data provider
	///    - undoManager: Document undo manager
	public init(
		stateProvider: any StateProviderProtocol<State>,
		contentProvider: any ContentProvider<State>,
		undoManager: UndoManager?) {
		self.contentProvider = contentProvider
		self.stateProvider = stateProvider
		self.undoManager = undoManager
	}
}

// MARK: - StateProviderProtocol
extension DocumentStorage: StateProviderProtocol {

	public var state: State {
		get {
			stateProvider.state
		}
		set {
			stateProvider.state = newValue
		}
	}

	public func modificate(_ block: (inout State) -> Void) {
		performOperation(block)
	}

	public func addObservation<O: AnyObject>(
		for object: O,
		handler: @escaping (O, State) -> Void
	) {
		stateProvider.addObservation(for: object, handler: handler)
	}
}

// MARK: - DocumentDataRepresentation
extension DocumentStorage: DocumentDataRepresentation {

	public func data(ofType typeName: String) throws -> Data {
		return try contentProvider.data(
			ofType: typeName,
			content: stateProvider.state
		)
	}

	public func read(from data: Data, ofType typeName: String) throws {
		stateProvider.state = try contentProvider.read(from: data, ofType: typeName)
		undoManager?.removeAllActions()
	}
}

// MARK: - Undo manager support
extension DocumentStorage {

	func canRedo() -> Bool {
		return undoManager?.canRedo ?? true
	}

	func redo() {
		undoManager?.redo()
	}

	func canUndo() -> Bool {
		return undoManager?.canUndo ?? false
	}

	func undo() {
		undoManager?.undo()
	}
}

// MARK: - Helpers
private extension DocumentStorage {

	func performOperation(with newData: Data, oldData: Data, oppositeOperation: Bool) {
		undoManager?.registerUndo(withTarget: self) { [weak self] target in
			guard let self else {
				return
			}
			self.performOperation(with: oldData, oldData: newData, oppositeOperation: true)
		}
		if oppositeOperation {
			guard let content = try? JSONDecoder().decode(State.self, from: newData) else {
				return
			}
			stateProvider.state = content
		}
	}

	func performOperation(_ block: (inout State) -> Void) {

		let encoder = JSONEncoder()

		let oldData = try? encoder.encode(stateProvider.state)
		block(&stateProvider.state)
		let newData = try? encoder.encode(stateProvider.state)
		guard let oldData, let newData else {
			return
		}
		performOperation(with: newData, oldData: oldData, oppositeOperation: false)
	}
}

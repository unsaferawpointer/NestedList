//
//  ContentProvider.swift
//  CoreModule
//
//  Created by Anton Cherkasov on 16.11.2024.
//

import Foundation

/// Data provider interface
public protocol ContentProvider<State> {

	associatedtype State

	/// - Returns: Data of the content
	func data(ofType typeName: String, content: State) throws -> Data

	/// - Returns content from data
	func read(from data: Data, ofType typeName: String) throws -> State

	func data(of content: State) throws -> Data

	func read(from data: Data) throws -> State
}

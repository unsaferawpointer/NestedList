//
//  DataProvider.swift
//  CoreModule
//
//  Created by Anton Cherkasov on 16.11.2024.
//

import Foundation

/// Data provider of board document
public final class DataProvider {

	public init() {}
}

// MARK: - ContentProvider
extension DataProvider: ContentProvider {

	public func data(ofType typeName: String, content: Content) throws -> Data {

		let formatter = BasicFormatter()

		let text = content.nodes.map {
			formatter.format($0)
		}.joined(separator: "\n")

		return text.data(using: .utf8)!
	}

	public func read(from data: Data, ofType typeName: String) throws -> Content {

		guard let type = DocumentType(rawValue: typeName.lowercased()) else {
			throw DocumentError.unexpectedFormat
		}

		guard let string = String(data: data, encoding: .utf8) else {
			throw DocumentError.unexpectedFormat
		}
		let parser = Parser()
		let nodes = parser.parse(from: string)
		return .init(nodes: nodes)
	}

	public func data(of content: Content) throws -> Data {
		let formatter = BasicFormatter()

		let text = content.nodes.map {
			formatter.format($0)
		}.joined(separator: "\n")

		return text.data(using: .utf8)!
	}

	public func read(from data: Data) throws -> Content {
		guard let string = String(data: data, encoding: .utf8) else {
			throw DocumentError.unexpectedFormat
		}
		let parser = Parser()
		let nodes = parser.parse(from: string)
		return .init(nodes: nodes)
	}
}

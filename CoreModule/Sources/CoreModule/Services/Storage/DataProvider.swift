//
//  DataProvider.swift
//  CoreModule
//
//  Created by Anton Cherkasov on 16.11.2024.
//

import Foundation

/// Data provider of board document
public final class DataProvider {

	private let parser: ParserProtocol

	public init(parser: ParserProtocol = Parser()) {
		self.parser = parser
	}
}

// MARK: - ContentProvider
extension DataProvider: ContentProvider {

	public func data(ofType typeName: String, content: Content) throws -> Data {

		let text = content.root.nodes.map {
			parser.format($0)
		}.joined(separator: "\n")

		return text.data(using: .utf8)!
	}

	public func read(from data: Data, ofType typeName: String) throws -> Content {

		guard let type = DocumentType(rawValue: typeName.lowercased()), type == .text else {
			throw DocumentError.unexpectedFormat
		}

		guard let string = String(data: data, encoding: .utf8) else {
			throw DocumentError.unexpectedFormat
		}

		let nodes = parser.parse(from: string)
		return .init(nodes: nodes)
	}

	public func data(of content: Content) throws -> Data {

		let text = content.root.nodes.map {
			parser.format($0)
		}.joined(separator: "\n")

		return text.data(using: .utf8)!
	}

	public func read(from data: Data) throws -> Content {
		guard let string = String(data: data, encoding: .utf8) else {
			throw DocumentError.unexpectedFormat
		}

		let nodes = parser.parse(from: string)
		return .init(nodes: nodes)
	}
}

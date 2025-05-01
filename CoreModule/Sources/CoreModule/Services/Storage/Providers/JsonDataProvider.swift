//
//  JsonDataProvider.swift
//  CoreModule
//
//  Created by Anton Cherkasov on 01.05.2025.
//

import Foundation

/// Data provider of board document
public final class JsonDataProvider {

	private let parser: ParserProtocol

	public init(parser: ParserProtocol = Parser()) {
		self.parser = parser
	}
}

// MARK: - ContentProvider
extension JsonDataProvider: ContentProvider {

	public func data(ofType typeName: String, content: Content) throws -> Data {
		let encoder = JSONEncoder()
		encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
		return try encoder.encode(content)
	}

	public func read(from data: Data, ofType typeName: String) throws -> Content {

		guard let type = DocumentType(rawValue: typeName.lowercased()), type == .nlist else {
			throw DocumentError.unexpectedFormat
		}

		return try JSONDecoder().decode(Content.self, from: data)
	}
}

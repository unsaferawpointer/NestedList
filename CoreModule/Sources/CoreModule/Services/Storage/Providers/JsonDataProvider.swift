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
		guard let type = DocumentType(rawValue: typeName.lowercased()) else {
			throw DocumentError.unexpectedFormat
		}

		switch type {
		case .nlist:
			let file = DocumentFile(version: type.lastVersion, content: content)
			let encoder = JSONEncoder()
			encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
			encoder.dateEncodingStrategy = .secondsSince1970
			return try encoder.encode(file)
		default:
			throw DocumentError.unexpectedFormat
		}
	}

	public func read(from data: Data, ofType typeName: String) throws -> Content {

		guard let type = DocumentType(rawValue: typeName.lowercased()) else {
			throw DocumentError.unexpectedFormat
		}

		switch type {
		case .nlist:
			return try migrate(data, type: type)
		default:
			throw DocumentError.unexpectedFormat
		}
	}
}

// MARK: - Helpers
private extension JsonDataProvider {

	func migrate(_ data: Data, type: DocumentType) throws -> Content {

		let decoder = JSONDecoder()
		decoder.dateDecodingStrategy = .secondsSince1970

		guard let versionedFile = try? decoder.decode(VersionedFile.self, from: data) else {
			throw DocumentError.unexpectedFormat
		}
		guard versionedFile.version <= type.lastVersion else {
			throw DocumentError.unknownVersion
		}
		guard let file = try? decoder.decode(DocumentFile<Content>.self, from: data) else {
			throw DocumentError.unexpectedFormat
		}
		return file.content
	}
}

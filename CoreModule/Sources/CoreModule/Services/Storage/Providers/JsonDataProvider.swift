//
//  JsonDataProvider.swift
//  CoreModule
//
//  Created by Anton Cherkasov on 01.05.2025.
//

import Foundation
import OSLog

/// Data provider of board document
public final class JsonDataProvider {

	private let logger = Logger(subsystem: "NestedList", category: "JsonDataProvider")

	public init() { }
}

// MARK: - ContentProvider
extension JsonDataProvider: ContentProvider {

	public func data(ofType typeName: String, content: DocumentContent) throws -> Data {
		log("Encoding data of type '\(typeName)'…")

		guard let type = DocumentType(rawValue: typeName.lowercased()) else {
			logError("Unexpected document type '\(typeName)'")
			throw DocumentError.unexpectedFormat
		}

		switch type {
		case .nlist:
			let file = DocumentFile(version: type.lastVersion, content: content)
			let encoder = JSONEncoder()
			encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
			encoder.dateEncodingStrategy = .secondsSince1970
			let data = try encoder.encode(file)
			log("Encoded \(data.count) bytes for version \(type.lastVersion.rawValue)")
			return data
		default:
			logError("Unsupported document type '\(type.rawValue)' for encoding")
			throw DocumentError.unexpectedFormat
		}
	}

	public func read(from data: Data, ofType typeName: String) throws -> DocumentContent {
		log("Decoding \(data.count) bytes of type '\(typeName)'…")

		guard let type = DocumentType(rawValue: typeName.lowercased()) else {
			logError("Unexpected document type '\(typeName)'")
			throw DocumentError.unexpectedFormat
		}

		switch type {
		case .nlist:
			return try migrate(data, type: type)
		default:
			logError("Unsupported document type '\(type.rawValue)' for decoding")
			throw DocumentError.unexpectedFormat
		}
	}
}

// MARK: - Helpers
private extension JsonDataProvider {

	func migrate(_ data: Data, type: DocumentType) throws -> DocumentContent {

		let decoder = JSONDecoder()
		decoder.dateDecodingStrategy = .secondsSince1970

		guard let versionedFile = try? decoder.decode(VersionedFile.self, from: data) else {
			logError("Failed to decode document version")
			throw DocumentError.unexpectedFormat
		}

		guard versionedFile.version.isBackwardCompatible(other: type.lastVersion) else {
			logError("Incompatible version \(versionedFile.version.rawValue), expected \(type.lastVersion.rawValue)")
			throw DocumentError.unknownVersion
		}

		guard let file = try? decoder.decode(DocumentFile<DocumentContent>.self, from: data) else {
			logError("Failed to decode document content")
			throw DocumentError.unexpectedFormat
		}

		log("Decoded content of version \(versionedFile.version.rawValue)")
		return file.content
	}

	func log(_ message: String) {
		logger.debug("📄 \(message, privacy: .public)")
	}

	func logError(_ message: String) {
		logger.error("📄 \(message, privacy: .public)")
	}
}

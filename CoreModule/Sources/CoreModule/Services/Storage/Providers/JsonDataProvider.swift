//
//  JsonDataProvider.swift
//  CoreModule
//
//  Created by Anton Cherkasov on 01.05.2025.
//

import Foundation

/// Data provider of board document
public final class JsonDataProvider {

	public init() { }
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

		let versionedFile: VersionedFile
		do {
			versionedFile = try decoder.decode(VersionedFile.self, from: data)
		} catch let error as DecodingError {
			print("VersionedFile decode error:", error)
			throw DocumentError.unexpectedFormat
		} catch {
			print("VersionedFile other error:", error)
			throw DocumentError.unexpectedFormat
		}

		guard versionedFile.version.isBackwardCompatible(other: type.lastVersion) else {
			throw DocumentError.unknownVersion
		}

		do {
			let file = try decoder.decode(DocumentFile<Content>.self, from: data)
			return file.content
		} catch let error as DecodingError {
			print("DocumentFile decode error:", error)
			throw DocumentError.unexpectedFormat
		} catch {
			print("DocumentFile other error:", error)
			throw DocumentError.unexpectedFormat
		}
	}
}

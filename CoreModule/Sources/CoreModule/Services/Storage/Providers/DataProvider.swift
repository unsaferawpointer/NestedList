//
//  DataProvider.swift
//  CoreModule
//
//  Created by Anton Cherkasov on 01.05.2025.
//

import Foundation
import OSLog

/// Data provider of board document
public final class DataProvider {

	private let logger = Logger(subsystem: "NestedList", category: "DataProvider")

	public init() { }
}

// MARK: - ContentProvider
extension DataProvider: ContentProvider {

	public func data(ofType typeName: String, content: Content) throws -> Data {
		log("Writing data of type '\(typeName)'…")
		do {
			let provider = try provider(for: typeName)
			let data = try provider.data(ofType: typeName, content: content)
			log("Wrote \(data.count) bytes of type '\(typeName)'")
			return data
		} catch {
			logError("Failed to write data of type '\(typeName)' — \(error.localizedDescription)")
			throw error
		}
	}

	public func read(from data: Data, ofType typeName: String) throws -> Content {
		log("Reading \(data.count) bytes of type '\(typeName)'…")
		do {
			let provider = try provider(for: typeName)
			let content = try provider.read(from: data, ofType: typeName)
			log("Read content of type '\(typeName)'")
			return content
		} catch {
			logError("Failed to read data of type '\(typeName)' — \(error.localizedDescription)")
			throw error
		}
	}
}

// MARK: - Helpers
private extension DataProvider {

	func provider(for typeName: String) throws -> any ContentProvider<Content> {
		guard let type = DocumentType(rawValue: typeName.lowercased()) else {
			logError("Unexpected document type '\(typeName)'")
			throw DocumentError.unexpectedFormat
		}
		log("Resolved provider for document type '\(type.rawValue)'")
		return switch type {
		case .text:
			TextDataProvider()
		case .nlist:
			JsonDataProvider()
		}
	}

	func log(_ message: String) {
		logger.debug("📄 \(message, privacy: .public)")
	}

	func logError(_ message: String) {
		logger.error("📄 \(message, privacy: .public)")
	}
}

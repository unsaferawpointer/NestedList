//
//  TextDataProvider.swift
//  CoreModule
//
//  Created by Anton Cherkasov on 16.11.2024.
//

import Foundation
import OSLog

/// Data provider of board document
public final class TextDataProvider {

	private let parser: ParserProtocol

	private let logger = Logger(subsystem: "NestedList", category: "TextDataProvider")

	public init(parser: ParserProtocol = Parser()) {
		self.parser = parser
	}
}

// MARK: - ContentProvider
extension TextDataProvider: ContentProvider {

	public func data(ofType typeName: String, content: DocumentContent) throws -> Data {
		log("Formatting content of type '\(typeName)'…")

		let text = content.tree()
			.map { parser.format($0) }
			.joined(separator: "\n")

		let data = text.data(using: .utf8)!
		log("Formatted \(data.count) bytes of type '\(typeName)'")
		return data
	}

	public func read(from data: Data, ofType typeName: String) throws -> DocumentContent {
		log("Parsing \(data.count) bytes of type '\(typeName)'…")

		guard let type = DocumentType(rawValue: typeName.lowercased()), type == .text else {
			logError("Unexpected document type '\(typeName)'")
			throw DocumentError.unexpectedFormat
		}

		guard let string = String(data: data, encoding: .utf8) else {
			logError("Failed to decode UTF-8 string of type '\(typeName)'")
			throw DocumentError.unexpectedFormat
		}

		let nodes = parser.parse(from: string).map {
			$0.map(type: DocumentNode.self)
		}
		log("Parsed \(nodes.count) root nodes of type '\(typeName)'")
		return .init(uuid: UUID(), nodes: nodes)
	}

	public func data(of content: DocumentContent) throws -> Data {
		log("Formatting content…")

		let text = content.tree()
			.map { parser.format($0) }
			.joined(separator: "\n")

		let data = text.data(using: .utf8)!
		log("Formatted \(data.count) bytes")
		return data
	}

	public func read(from data: Data) throws -> DocumentContent {
		log("Parsing \(data.count) bytes…")

		guard let string = String(data: data, encoding: .utf8) else {
			logError("Failed to decode UTF-8 string")
			throw DocumentError.unexpectedFormat
		}

		let nodes = parser.parse(from: string).map {
			$0.map(type: DocumentNode.self)
		}
		log("Parsed \(nodes.count) root nodes")
		return .init(uuid: UUID(), nodes: nodes)
	}
}

// MARK: - Helpers
private extension TextDataProvider {

	func log(_ message: String) {
		logger.debug("📄 \(message, privacy: .public)")
	}

	func logError(_ message: String) {
		logger.error("📄 \(message, privacy: .public)")
	}
}

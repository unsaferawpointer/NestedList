//
//  DataProvider.swift
//  CoreModule
//
//  Created by Anton Cherkasov on 01.05.2025.
//

import Foundation

/// Data provider of board document
public final class DataProvider {

	public init() { }
}

// MARK: - ContentProvider
extension DataProvider: ContentProvider {

	public func data(ofType typeName: String, content: Content) throws -> Data {
		let provider = try provider(for: typeName)
		return try provider.data(ofType: typeName, content: content)
	}

	public func read(from data: Data, ofType typeName: String) throws -> Content {
		let provider = try provider(for: typeName)
		return try provider.read(from: data, ofType: typeName)
	}
}

// MARK: - Helpers
private extension DataProvider {

	func provider(for typeName: String) throws -> any ContentProvider<Content> {
		guard let type = DocumentType(rawValue: typeName.lowercased()) else {
			throw DocumentError.unexpectedFormat
		}
		return switch type {
		case .text:
			TextDataProvider()
		case .nlist:
			JsonDataProvider()
		}
	}
}

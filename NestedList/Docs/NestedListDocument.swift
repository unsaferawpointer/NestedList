//
//  NestedListDocument.swift
//  NestedList
//
//  Created by Anton Cherkasov on 12.11.2024.
//

import SwiftUI
import UniformTypeIdentifiers

extension UTType {

	static var text: UTType {
		UTType(importedAs: "public.plain-text")
	}
}

struct NestedListDocument {

	var text: String

	init(text: String = "Hello, world!") {
		self.text = text
	}
}

// MARK: - FileDocument
extension NestedListDocument: FileDocument {

	static var readableContentTypes: [UTType] {
		[.text]
	}

	init(configuration: ReadConfiguration) throws {
		guard let data = configuration.file.regularFileContents,
			  let string = String(data: data, encoding: .utf8)
		else {
			throw CocoaError(.fileReadCorruptFile)
		}
		text = string
	}

	func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
		let data = text.data(using: .utf8)!
		return .init(regularFileWithContents: data)
	}
}

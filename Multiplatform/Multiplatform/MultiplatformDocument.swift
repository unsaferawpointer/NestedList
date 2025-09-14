//
//  MultiplatformDocument.swift
//  Multiplatform
//
//  Created by Anton Cherkasov on 14.09.2025.
//

import SwiftUI
import UniformTypeIdentifiers

nonisolated struct MultiplatformDocument: FileDocument {
    var text: String

    init(text: String = "Hello, world!") {
        self.text = text
    }

    static let readableContentTypes = [
		UTType(exportedAs: "dev.zeroindex.nested-list.doc", conformingTo: .data)
    ]

	static var writableContentTypes: [UTType] = [
		UTType(exportedAs: "dev.zeroindex.nested-list.doc", conformingTo: .data)
	]

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

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

	var nodes: [Node<Item>]

	init(nodes: [Node<Item>] = []) {
		self.nodes = nodes
	}
}

// MARK: - FileDocument
extension NestedListDocument: FileDocument {

	static var readableContentTypes: [UTType] {
		[.text]
	}

	init(configuration: ReadConfiguration) throws {
		guard
			let data = configuration.file.regularFileContents,
			let string = String(data: data, encoding: .utf8)
		else {
			throw CocoaError(.fileReadCorruptFile)
		}
		self.nodes = TextParser(configuration: .default).parse(from: string)
	}

	func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
		let text = nodes.map {
			BasicFormatter().format($0)
		}.joined(separator: "\n")
		let data = text.data(using: .utf8)!
		return .init(regularFileWithContents: data)
	}
}

extension NestedListDocument {

	mutating func insert(to target: UUID?) {

		let item = Item(text: "New Item")
		let node = Node<Item>(value: item)

		guard let target else {
			nodes.append(node)
			return
		}
		for i in 0..<nodes.count {
			nodes[i].insert(node, to: target)
		}
	}
}

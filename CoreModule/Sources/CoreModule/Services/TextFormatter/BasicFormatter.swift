//
//  BasicFormatter.swift
//  CoreModule
//
//  Created by Anton Cherkasov on 16.11.2024.
//

import Foundation
import Hierarchy

protocol BasicFormatterProtocol {
	func format(_ node: Node<Item>) -> String
}

final class BasicFormatter {

	let format: Format

	// MARK: - Initialization

	init(format: Format = Format(indent: .tab)) {
		self.format = format
	}
}

// MARK: - BasicFormatterProtocol
extension BasicFormatter: BasicFormatterProtocol {

	func format(_ node: Node<Item>) -> String {
		return text(for: node, indent: 0).joined(separator: "\n")
	}
}

// MARK: - Helpers
private extension BasicFormatter {

	func filter(nodes: [Node<Item>]) -> [Node<Item>] {

		var cache = Set<UUID>()

		let flatten = nodes.flatMap { $0.children }

		for node in flatten {
			guard !cache.contains(node.id) else {
				continue
			}
			var queue = [node]
			while !queue.isEmpty {
				let current = queue.remove(at: 0)
				cache.insert(current.id)
				for child in current.children {
					queue.insert(child, at: 0)
				}
			}
		}

		return nodes.filter { node in
			!cache.contains(node.id)
		}
	}

	func text(for node: Node<Item>, indent: Int) -> [String] {
		let indentPrefix = Array(repeating: format.indent.value, count: indent).joined()
		let line = indentPrefix + " " + node.value.text
		return [line] + node.children.flatMap { text(for: $0, indent: indent + 1) }
	}
}

// MARK: - Nested data structs
extension BasicFormatter {

	struct Format {
		var indent: Indent
	}

	enum Indent {
		case space(value: Int)
		case tab

		var value: String {
			switch self {
			case .space(let value):
				return Array(repeating: " ", count: value).joined()
			case .tab:
				return "\t"
			}
		}
	}
}

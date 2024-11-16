//
//  Parser.swift
//  TextParsing
//
//  Created by Anton Cherkasov on 16.11.2024.
//

import Foundation
import Hierarchy

protocol ParserProtocol {
	func parse(from text: String) -> [Node<Parser.Line>]
}

public final class Parser {

	typealias Model = Line
}

// MARK: - ParserProtocol
extension Parser: ParserProtocol {

	func parse(from text: String) -> [Node<Model>] {

		var lines = parseLines(text: text)

		// Trim

		let minIndent = lines.map(\.indent).min() ?? 0
		lines = lines.map {
			Line(indent: $0.indent - minIndent, text: $0.text)
		}

		// Normilize indents

		var current: Int = -1

		for index in 0..<lines.count {

			let max = current + 1

			let indent = lines[index].indent
			lines[index].indent = min(indent, max)

			current = min(indent, max)
		}

		// Build tree structure

		var result: [Node<Model>] = []
		var cache: [Int: Node<Model>] = [:]

		for line in lines {

			let node = Node<Model>(value: line)

			if line.indent == 0 {
				result.append(node)
			} else if let parent = cache[line.indent - 1] {
				parent.children.append(node)
			}

			cache[line.indent] = node
		}
		return result
	}
}

// MARK: - Helpers
private extension Parser {

	func parseLines(text: String) -> [Line] {
		var result: [Line] = []
		text.enumerateLines { line, stop in
			let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)

			// Skip empty line
			guard !trimmed.isEmpty else {
				return
			}

			let line = Line(indent: line.indent, text: trimmed)
			result.append(line)
		}
		return result
	}
}

// MARK: - Nested data structs
extension Parser {

	struct Line {
		var indent: Int
		var text: String
	}
}

// MARK: - Extensions

private extension String {

	var indent: Int {

		let tab: Character = "\t"

		let prefix = self.prefix(while: { $0.isPrefix })
		let spacesCount = prefix.reduce(0) { partialResult, character in
			return partialResult + (character.spacesWidth ?? 0)
		}
		return spacesCount / (tab.spacesWidth ?? 1)
	}
}

private extension Character {

	var isPrefix: Bool {
		switch self {
		case "\u{00A0}", "\t":	true
		default:				false
		}
	}

	var spacesWidth: Int? {
		switch self {
		case "\u{00A0}":	1
		case "\t":			4
		default:			nil
		}
	}
}

//
//  Parser.swift
//  TextParsing
//
//  Created by Anton Cherkasov on 16.11.2024.
//

import Foundation
import Hierarchy

public protocol ParserProtocol {
	func parse(from text: String) -> [Node<Item>]
}

public final class Parser {

	public typealias Model = Item

	// MARK: - Initialization

	public init() { }
}

// MARK: - ParserProtocol
extension Parser: ParserProtocol {

	public func parse(from text: String) -> [Node<Model>] {

		var lines = parseLines(text: text)

		// Trim

		let minIndent = lines.map(\.indent).min() ?? 0
		lines = lines.map {
			Line(
				indent: $0.indent - minIndent,
				prefix: $0.prefix,
				text: $0.text,
				isDone: $0.isDone,
				isMarked: $0.isMarked,
				hasColon: $0.hasColon
			)
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

			let item = Item(
				uuid: .init(),
				isDone: line.isDone,
				text: line.text,
				style: line.hasColon
					? .section
					: .item
			)
			let node = Node<Model>(value: item)

			if line.indent == 0 {
				result.append(node)
				node.parent = nil
			} else if let parent = cache[line.indent - 1] {
				parent.children.append(node)
				node.parent = parent
			}

			cache[line.indent] = node
		}
		return result
	}
}

// MARK: - Helpers
private extension Parser {

	/*
	Project:
		* Body @done
	 */
	func parseLines(text: String) -> [Line] {
		var result: [Line] = []
		text.enumerateLines { line, stop in

			var trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)

			// Prefix

			guard let first = trimmed.first else {
				return
			}
			let prefix = Prefix(rawValue: first)
			if prefix != nil {
				trimmed.removeFirst()
			}

			// Done annotation

			let annotation = "@" + Annotation.done.rawValue

			let isDone = trimmed.contains(annotation)
			if isDone {
				trimmed = trimmed.replacing(annotation, with: "")
			}

			trimmed = trimmed.trimmingCharacters(in: .whitespaces)

			// Colon

			let hasColon = trimmed.hasSuffix(":")
			if hasColon {
				trimmed.removeLast()
			}

			// Mark annotation

			let markAnnotation = "@" + Annotation.mark.rawValue
			let isMarked = trimmed.contains(markAnnotation)
			if isMarked {
				trimmed = trimmed.replacing(markAnnotation, with: "")
			}

			let line = Line(
				indent: line.indent,
				prefix: prefix,
				text: trimmed,
				isDone: isDone,
				isMarked: isMarked,
				hasColon: hasColon
			)
			result.append(line)
		}
		return result
	}
}

// MARK: - Nested data structs
extension Parser {

	struct Line {
		var indent: Int
		var prefix: Prefix?
		var text: String
		var isDone: Bool
		var isMarked: Bool
		var hasColon: Bool
	}

	enum Annotation: String {
		case done
		case mark
	}
}

// MARK: - Extensions

private extension String {

	var indent: Int {

		let tab: Character = "\t"

		let prefix = self.prefix(while: { $0.isWhitespace })
		let spacesCount = prefix.reduce(0) { partialResult, character in
			return partialResult + (character.spacesWidth ?? 0)
		}
		return spacesCount / (tab.spacesWidth ?? 1)
	}
}

private extension Character {

	var isWhitespace: Bool {
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

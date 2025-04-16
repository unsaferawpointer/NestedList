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
	func format(_ node: Node<Item>) -> String
}

public final class Parser {

	public typealias Model = Item

	let format: Format

	// MARK: - Initialization

	public init(format: Format = Format(indent: .tab)) {
		self.format = format
	}
}

// MARK: - ParserProtocol
extension Parser: ParserProtocol {

	public func parse(from text: String) -> [Node<Model>] {

		var lines = parseLines(text: text)

		// Trim

		let minIndent = lines.map(\.indent).min() ?? 0
		lines = lines.map {
			$0.shifted(shift: -minIndent)
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
		var previous: Node<Model>? = nil

		for line in lines {

			let isNote = line.prefix == nil && !line.hasColon

			if isNote, let previous {
				if previous.value.note != nil {
					previous.value.note?.append(line.text)
				} else {
					previous.value.note = line.text
				}
				continue
			}

			let isDone = contains(prefix: .ex, orAnnotation: .done, in: line)
			let isMarked = contains(prefix: .asterisk, orAnnotation: .mark, in: line)
			let isFolded = contains(prefix: .greaterThan, orAnnotation: .fold, in: line)

			let style: Item.Style = line.hasColon ? .section : .item

			let item = Item(
				uuid: .init(),
				isDone: isDone && style == .item,
				isMarked: isMarked && style == .item,
				isFolded: isFolded,
				text: line.text,
				style: style
			)
			let node = Node<Model>(value: item)
			previous = node

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

	public func format(_ node: Node<Item>) -> String {
		return text(for: node, indent: 0).joined(separator: "\n")
	}
}

// MARK: - Helpers
extension Parser {

	func contains(prefix: Prefix, orAnnotation annotation: Annotation, in line: Line) -> Bool {
		guard line.prefix == prefix else {
			return line.annotations.contains(annotation)
		}
		return true
	}
}

// MARK: - Helpers
private extension Parser {

	func text(for node: Node<Item>, indent: Int) -> [String] {
		let item = node.value

		let indentPrefix = Array(repeating: format.indent.value, count: indent).joined()

		let prefixSign: Prefix = {
			guard item.style == .item else {
				return item.isFolded ? .greaterThan : .dash
			}

			return switch (item.isDone, item.isMarked) {
			case (true, _): 		.ex
			case (false, true): 	.asterisk
			default: 				.dash
			}
		}()

		let trailingSign = switch item.style {
			case .section: ":"
			case .item: ""
		}

		let line = indentPrefix + [String(prefixSign.rawValue), item.text, trailingSign]
			.filter { !$0.isEmpty }
			.joined(separator: " ")

		var lines = [line]
		if let note = item.note {
			lines.append(indentPrefix + note)
		}

		return lines + node.children.flatMap { text(for: $0, indent: indent + 1) }
	}

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

			// Annotations

			var annotations = Set<Annotation>()
			Annotation.allCases.forEach {
				if trimmed.replace($0) {
					annotations.insert($0)
				}
			}

			// Colon

			trimmed = trimmed.trimmingCharacters(in: .whitespaces)

			let hasColon = trimmed.hasSuffix(":")
			if hasColon {
				trimmed.removeLast()
			}

			let line = Line(
				indent: line.indent,
				prefix: prefix,
				text: trimmed,
				annotations: annotations,
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
		var annotations: Set<Annotation>
		var hasColon: Bool

		func shifted(shift: Int) -> Line {
			Line(
				indent: indent + shift,
				prefix: prefix,
				text: text,
				annotations: annotations,
				hasColon: hasColon
			)
		}
	}
}

enum Annotation: String {
	case done
	case mark
	case fold
}

// MARK: - CaseIterable
extension Annotation: CaseIterable { }

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

	mutating func replace(_ annotation: Annotation) -> Bool {
		let substring = "@" + annotation.rawValue
		guard self.contains(substring) else {
			return false
		}
		replace(substring, with: "", maxReplacements: 1)
		return true
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

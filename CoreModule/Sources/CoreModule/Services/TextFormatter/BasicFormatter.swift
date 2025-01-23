//
//  BasicFormatter.swift
//  CoreModule
//
//  Created by Anton Cherkasov on 16.11.2024.
//

import Foundation
import Hierarchy

public protocol BasicFormatterProtocol {
	func format(_ node: Node<Item>) -> String
}

public final class BasicFormatter {

	let format: Format

	// MARK: - Initialization

	public init(format: Format = Format(indent: .tab)) {
		self.format = format
	}
}

// MARK: - BasicFormatterProtocol
extension BasicFormatter: BasicFormatterProtocol {

	public func format(_ node: Node<Item>) -> String {
		return text(for: node, indent: 0).joined(separator: "\n")
	}
}

// MARK: - Helpers
private extension BasicFormatter {

	func text(for node: Node<Item>, indent: Int) -> [String] {
		let item = node.value

		let indentPrefix = Array(repeating: format.indent.value, count: indent).joined()

		let sign = (item.style == .item) ? String(Prefix.dash.rawValue) : ""

		let body = item.text + (item.style == .section ? ":" : "")

		let markAnnotation = node.value.isMarked ? "@" + Annotation.mark.rawValue : ""
		let doneAnnotation = node.value.isDone ? "@" + Annotation.done.rawValue : ""

		let line = indentPrefix + [sign, body, doneAnnotation, markAnnotation].filter { !$0.isEmpty }.joined(separator: " ")

		var lines = [line]
		if let note = item.note {
			lines.append(indentPrefix + note)
		}

		return lines + node.children.flatMap { text(for: $0, indent: indent + 1) }
	}
}

// MARK: - Nested data structs
public extension BasicFormatter {

	struct Format {

		var indent: Indent

		// MARK: - Initialization

		public init(indent: Indent) {
			self.indent = indent
		}
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

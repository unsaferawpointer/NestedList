//
//  Item.swift
//  CoreModule
//
//  Created by Anton Cherkasov on 16.11.2024.
//

import Foundation
import Hierarchy

public struct Item {

	public var uuid: UUID

	public var text: String

	public var note: String?

	public var options: ItemOptions

	public var style: ItemStyle

	// MARK: - Initialization

	public init(
		uuid: UUID = UUID(),
		text: String,
		note: String? = nil,
		options: ItemOptions = [],
		style: ItemStyle = .item
	) {
		self.uuid = uuid
		self.text = text
		self.note = note
		self.options = options
		self.style = style
	}
}

// MARK: - Identifiable
extension Item: Identifiable {

	public var id: UUID {
		uuid
	}
}

// MARK: - Public Interface
public extension Item {

	func copy(with newId: UUID = .init()) -> Item {
		return Item(
			uuid: newId,
			text: text,
			note: note,
			options: options,
			style: style
		)
	}
}

// MARK: - Computed properties
public extension Item {

	var isStrikethrough: Bool {
		get {
			options.contains(.strikethrough)
		}
		set {
			if newValue {
				options.insert(.strikethrough)
			} else {
				options.remove(.strikethrough)
			}
		}
	}

	var isMarked: Bool {
		get {
			options.contains(.marked)
		}
		set {
			if newValue {
				options.insert(.marked)
			} else {
				options.remove(.marked)
			}
		}
	}

	var isFolded: Bool {
		get {
			options.contains(.folded)
		}
		set {
			if newValue {
				options.insert(.folded)
			} else {
				options.remove(.folded)
			}
		}
	}
}

// MARK: - Codable
extension Item: Codable { }

// MARK: - NodeValue
extension Item: NodeValue {

	public mutating func generateIdentifier() {
		self.uuid = UUID()
	}
}

// MARK: - Nested data structs
public extension Item {

	enum Style: Int, Codable {
		case item
		case section
	}
}

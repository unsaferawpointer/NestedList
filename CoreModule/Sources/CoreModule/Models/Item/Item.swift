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

	public var properties: Properties

	// MARK: - Initialization

	public init(
		uuid: UUID = UUID(),
		isStrikethrough: Bool = false,
		isMarked: Bool = false,
		isFolded: Bool = false,
		text: String,
		note: String? = nil,
		style: Style = .item
	) {
		self.uuid = uuid
		self.properties = Properties(
			isStrikethrough: isStrikethrough,
			isMarked: isMarked,
			isFolded: isFolded,
			text: text,
			note: note,
			style: style
		)
	}
}

// MARK: - Identifiable
extension Item: Identifiable {

	public var id: UUID {
		uuid
	}
}

// MARK: - Computed properties
public extension Item {

	var isStrikethrough: Bool {
		get {
			properties.isStrikethrough
		}
		set {
			properties.isStrikethrough = newValue
		}
	}

	var isMarked: Bool {
		get {
			properties.isMarked
		}
		set {
			properties.isMarked = newValue
		}
	}

	var isFolded: Bool {
		get {
			properties.isFolded
		}
		set {
			properties.isFolded = newValue
		}
	}

	var text: String {
		get {
			properties.text
		}
		set {
			properties.text = newValue
		}
	}

	var note: String? {
		get {
			properties.note
		}
		set {
			properties.note = newValue
		}
	}

	var style: Style {
		get {
			properties.style
		}
		set {
			properties.style = newValue
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

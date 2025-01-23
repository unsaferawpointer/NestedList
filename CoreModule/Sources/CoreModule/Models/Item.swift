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

	public var isDone: Bool

	public var isMarked: Bool

	public var text: String

	public var note: String?

	public var style: Style

	// MARK: - Initialization

	public init(
		uuid: UUID = UUID(),
		isDone: Bool = false,
		isMarked: Bool = false,
		text: String,
		note: String? = nil,
		style: Style
	) {
		self.uuid = uuid
		self.isDone = isDone
		self.isMarked = isMarked
		self.text = text
		self.note = note
		self.style = style
	}
}

// MARK: - Identifiable
extension Item: Identifiable {

	public var id: UUID {
		uuid
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

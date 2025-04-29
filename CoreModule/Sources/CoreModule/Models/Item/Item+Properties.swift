//
//  Item+Properties.swift
//  CoreModule
//
//  Created by Anton Cherkasov on 29.04.2025.
//

import Foundation

// MARK: - Nested data structs
public extension Item {

	struct Properties {

		public var isStrikethrough: Bool

		public var isMarked: Bool

		public var isFolded: Bool

		public var text: String

		public var note: String?

		public var style: Style

		init(
			isStrikethrough: Bool = false,
			isMarked: Bool = false,
			isFolded: Bool = false,
			text: String,
			note: String? = nil,
			style: Style = .item
		) {
			self.isStrikethrough = isStrikethrough
			self.isMarked = isMarked
			self.isFolded = isFolded
			self.text = text
			self.note = note
			self.style = style
		}
	}
}

// MARK: - Codable
extension Item.Properties: Codable { }

// MARK: - Hashable
extension Item.Properties: Hashable { }

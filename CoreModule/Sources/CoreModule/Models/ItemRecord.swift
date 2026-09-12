//
//  ItemRecord.swift
//  CoreModule
//
//  Created by Anton Cherkasov on 11.09.2026.
//

import Foundation

/// A file-backed representation of an item in a NestedList document.
struct ItemRecord {

	/// The item identifier.
	var id: UUID

	/// The item content.
	var content: ItemContent
}

// MARK: - Codable
extension ItemRecord: Codable {

	init(from decoder: any Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.init(
			id: try container.decode(UUID.self, forKey: .uuid),
			content: try ItemContent(from: decoder)
		)
	}

	func encode(to encoder: any Encoder) throws {
		try content.encode(to: encoder)
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(id, forKey: .uuid)
	}

	// MARK: - Nested data structs

	enum CodingKeys: String, CodingKey {
		case uuid
	}
}

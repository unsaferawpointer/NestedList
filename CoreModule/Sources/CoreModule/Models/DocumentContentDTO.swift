//
//  DocumentContentDTO.swift
//  CoreModule
//

import Foundation
import Hierarchy

/// An independent, file-backed representation of document content.
public struct DocumentContentDTO {

	public var uuid: UUID?

	public var items: [DocumentNode<Container<ItemContent, UUID>>]

	// MARK: - Initialization

	public init(uuid: UUID?, items: [DocumentNode<Container<ItemContent, UUID>>] = []) {
		self.uuid = uuid
		self.items = items
	}
}

// MARK: - Codable
extension DocumentContentDTO: Codable {

	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		let version: Version? = if let key = CodingUserInfoKey.documentVersion {
			decoder.userInfo[key] as? Version
		} else {
			nil
		}

		if version?.major == 1 || version?.major == 2 {
			let legacyNodes = try container.decode([DocumentNode<Item>].self, forKey: .items)
			self.items = legacyNodes.map { node in
				node.map { value in
					Container.item(id: value.id, content: value.content)
				}
			}
		} else {
			self.items = try container.decode([DocumentNode<Container<ItemContent, UUID>>].self, forKey: .items)
		}
		self.uuid = try? container.decodeIfPresent(UUID.self, forKey: .uuid)
	}

	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(items, forKey: .items)
		try container.encode(uuid ?? UUID(), forKey: .uuid)
	}
}

// MARK: - Nested data structs
private extension DocumentContentDTO {

	enum CodingKeys: CodingKey {
		case items
		case uuid
	}
}

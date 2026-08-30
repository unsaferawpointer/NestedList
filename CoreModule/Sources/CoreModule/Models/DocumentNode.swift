//
//  DocumentNode.swift
//  CoreModule
//
//  Created by Anton Cherkasov on 30.08.2026.
//

import Foundation
import Hierarchy

/// A file-backed representation of a document item and its nested children.
///
/// `DocumentNode` is primarily used while encoding and decoding document files. It bridges
/// the stored `items` hierarchy in `DocumentContent` with the in-memory tree APIs by
/// conforming to `TreeNode`, keeping persistence details out of the mutable document model.
struct DocumentNode: TreeNode {

	var value: Item
	var children: [DocumentNode]

	init(value: Item, children: [DocumentNode]) {
		self.value = value
		self.children = children
	}
}

// MARK: - Nested data structs
extension DocumentNode {

	enum CodingKeys: CodingKey {
		case value
		case children
	}
}

// MARK: - Decodable
extension DocumentNode: Decodable {

	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)

		let value = try container.decode(Value.self, forKey: .value)
		let children = try container.decodeIfPresent([DocumentNode].self, forKey: .children) ?? []

		self.init(value: value, children: children)
	}
}

// MARK: - Encodable
extension DocumentNode: Encodable {

	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)

		try container.encode(value, forKey: .value)
		if !children.isEmpty {
			try container.encode(children, forKey: .children)
		}
	}
}

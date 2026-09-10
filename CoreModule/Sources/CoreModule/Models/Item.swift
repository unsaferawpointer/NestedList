//
//  Item.swift
//  CoreModule
//
//  Created by Anton Cherkasov on 14.03.2026.
//

import Foundation
import Hierarchy

public struct Item {

	public var id: UUID

	public var content: ItemContent

	// MARK: - Initialization

	public init(id: UUID, content: ItemContent) {
		self.id = id
		self.content = content
	}
}

public typealias ResolvedItem = Resolved<Item>

// MARK: - ItemContent interface
public extension Item {

	var uuid: UUID {
		get { id }
		set { id = newValue }
	}

	var text: String {
		get { content.text }
		set { content.text = newValue }
	}

	var note: String? {
		get { content.note }
		set { content.note = newValue }
	}

	var options: ItemOptions {
		get { content.options }
		set { content.options = newValue }
	}

	var view: View {
		get { content.view }
		set { content.view = newValue }
	}

	// MARK: - Appearance

	var iconName: IconName? {
		get { content.iconName }
		set { content.iconName = newValue }
	}

	var tintColor: ItemColor? {
		get { content.tintColor }
		set { content.tintColor = newValue }
	}

	var isStrikethrough: Bool {
		get { content.isStrikethrough }
		set { content.isStrikethrough = newValue }
	}

	var isSubitemsHidden: Bool {
		get { content.isSubitemsHidden }
		set { content.isSubitemsHidden = newValue }
	}

	var properties: ItemProperties {
		get { content.properties }
		set { content.properties = newValue }
	}

	// MARK: - Initialization

	init(
		uuid: UUID = UUID(),
		text: String,
		note: String? = nil,
		options: ItemOptions = [],
		view: View = .list,
		iconName: IconName? = nil,
		tintColor: ItemColor? = nil
	) {
		self.init(
			id: uuid,
			content: ItemContent(
				text: text,
				note: note,
				options: options,
				view: view,
				iconName: iconName,
				tintColor: tintColor
			)
		)
	}

	init(uuid: UUID = UUID(), properties: ItemProperties) {
		self.init(
			id: uuid,
			content: ItemContent(properties: properties)
		)
	}

	// MARK: - Public Interface

	func copy(with newId: UUID = .init()) -> Item {
		return Item(
			id: newId,
			content: content
		)
	}

	// MARK: - Nested data structs

	typealias View = ItemContent.View

	typealias Style = ItemContent.Style
}

// MARK: - MutableIdentifiable
extension Item: MutableIdentifiable { }

// MARK: - Hashable
extension Item: Hashable { }

// MARK: - Codable
extension Item: Codable {

	public init(from decoder: any Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.init(
			id: try container.decode(UUID.self, forKey: .uuid),
			content: try ItemContent(from: decoder)
		)
	}

	public func encode(to encoder: any Encoder) throws {
		try content.encode(to: encoder)
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(id, forKey: .uuid)
	}

	enum CodingKeys: String, CodingKey {
		case uuid
	}
}

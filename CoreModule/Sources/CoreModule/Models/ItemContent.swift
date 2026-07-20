//
//  ItemContent.swift
//  CoreModule
//
//  Created by Anton Cherkasov on 16.11.2024.
//

import Foundation
import Hierarchy

public struct ItemContent {

	public var uuid: UUID

	public var text: String

	public var note: String?

	public var options: ItemOptions

	// MARK: - Appearance

	public var iconName: IconName?

	public var tintColor: ItemColor?

	// MARK: - Initialization

	public init(
		uuid: UUID = UUID(),
		text: String,
		note: String? = nil,
		options: ItemOptions = [],
		iconName: IconName? = nil,
		tintColor: ItemColor? = nil
	) {
		self.uuid = uuid
		self.text = text
		self.note = note
		self.options = options
		self.iconName = iconName
		self.tintColor = tintColor
	}

	public init(uuid: UUID = UUID(), properties: ItemProperties) {
		self.uuid = uuid
		self.text = properties.text
		self.note = properties.note
		self.options = properties.options
		self.iconName = properties.iconName
		self.tintColor = properties.tintColor
	}
}

// MARK: - Identifiable
extension ItemContent: MutableIdentifiable {

	public var id: UUID {
		get { uuid }
		set { uuid = newValue }
	}
}

// MARK: - Hashable
extension ItemContent: Hashable { }

// MARK: - Public Interface
public extension ItemContent {

	func copy(with newId: UUID = .init()) -> ItemContent {
		return ItemContent(
			uuid: newId,
			text: text,
			note: note,
			options: options,
			iconName: iconName,
			tintColor: tintColor
		)
	}
}

// MARK: - Computed properties
public extension ItemContent {

	var isStrikethrough: Bool {
		get { options.contains(.strikethrough) }
		set { options.set(.strikethrough, enabled: newValue) }
	}

	var isSubitemsHidden: Bool {
		get { options.contains(.hideSubitems) }
		set { options.set(.hideSubitems, enabled: newValue) }
	}

	var properties: ItemProperties {
		get {
			ItemProperties(
				text: text,
				note: note,
				options: options,
				iconName: iconName,
				tintColor: tintColor
			)
		}
		set {
			self.text = newValue.text
			self.note = newValue.note
			self.options = newValue.options
			self.iconName = newValue.iconName
			self.tintColor = newValue.tintColor
		}
	}
}

// MARK: - Codable
extension ItemContent: Codable {
	
	enum CodingKeys: String, CodingKey {
		case uuid
		case text
		case note
		case options
		case iconName
		case tintColor
		case style
	}
	
	public init(from decoder: any Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)

		self.uuid = try container.decode(UUID.self, forKey: .uuid)
		self.text = try container.decode(String.self, forKey: .text)
		self.note = try container.decodeIfPresent(String.self, forKey: .note)
		self.options = try container.decode(ItemOptions.self, forKey: .options)

		guard let key = CodingUserInfoKey.documentVersion, let version = decoder.userInfo[key] as? Version else {
			throw DecodingError.dataCorrupted(.init(codingPath: decoder.codingPath, debugDescription: "No document version found"))
		}

		// MARK: - Versioning

		switch version.major {
		case 1:
			let style = try container.decode(ItemStyle.self, forKey: .style)
			if case let .section(icon) = style {
				self.iconName = icon?.name
				self.tintColor = options.contains(.marked) ? .yellow : icon?.color
			}
		case 2:
			self.iconName = try? container.decodeIfPresent(IconName.self, forKey: .iconName)
			self.tintColor = try? container.decodeIfPresent(ItemColor.self, forKey: .tintColor)
		default:
			throw DecodingError.dataCorrupted(.init(codingPath: decoder.codingPath, debugDescription: "Unsupported document version: \(version)"))
		}
	}
	
	public func encode(to encoder: any Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(uuid, forKey: .uuid)
		try container.encode(text, forKey: .text)
		try container.encodeIfPresent(note, forKey: .note)
		try container.encode(options, forKey: .options)
		try container.encodeIfPresent(iconName, forKey: .iconName)
		try container.encodeIfPresent(tintColor, forKey: .tintColor)
	}
}

// MARK: - Nested data structs
public extension ItemContent {

	enum Style: Int, Codable {
		case item
		case section
	}
}

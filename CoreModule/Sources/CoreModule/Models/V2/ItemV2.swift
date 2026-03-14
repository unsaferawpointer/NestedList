//
//  ItemV2.swift
//  CoreModule
//
//  Created by Anton Cherkasov on 16.11.2024.
//

import Foundation
import Hierarchy

public struct ItemV2 {

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
}

// MARK: - Identifiable
extension ItemV2: Identifiable {

	public var id: UUID {
		uuid
	}
}

// MARK: - Public Interface
public extension ItemV2 {

	func copy(with newId: UUID = .init()) -> ItemV2 {
		return ItemV2(
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
public extension ItemV2 {

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
}

// MARK: - Codable
extension ItemV2: Codable {

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

		let decodedIconName = try container.decodeIfPresent(IconName.self, forKey: .iconName)
		let decodedTintColor = try container.decodeIfPresent(ItemColor.self, forKey: .tintColor)

		if let style = try container.decodeIfPresent(ItemStyle.self, forKey: .style),
		   case let .section(icon) = style {
			self.iconName = decodedIconName ?? icon?.name
			self.tintColor = decodedTintColor ?? icon?.color
		} else {
			self.iconName = decodedIconName
			self.tintColor = decodedTintColor
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

// MARK: - IdentifiableValue
extension ItemV2: IdentifiableValue {

	public mutating func generateId() {
		self.uuid = UUID()
	}
}

// MARK: - Nested data structs
public extension ItemV2 {

	enum Style: Int, Codable {
		case item
		case section
	}
}

//
//  ItemContent.swift
//  CoreModule
//
//  Created by Anton Cherkasov on 16.11.2024.
//

import Foundation

public struct ItemContent {

	public var text: String

	public var note: String?

	public var options: ItemOptions

	public var view: View

	// MARK: - Appearance

	public var iconName: IconName?

	public var tintColor: ItemColor?

	// MARK: - Initialization

	public init(
		text: String,
		note: String? = nil,
		options: ItemOptions = [],
		view: View = .list,
		iconName: IconName? = nil,
		tintColor: ItemColor? = nil
	) {
		self.text = text
		self.note = note
		self.options = options
		self.view = view
		self.iconName = iconName
		self.tintColor = tintColor
	}

	public init(properties: ItemProperties) {
		self.text = properties.text
		self.note = properties.note
		self.options = properties.options
		self.view = .list
		self.iconName = properties.iconName
		self.tintColor = properties.tintColor
	}
}

// MARK: - Hashable
extension ItemContent: Hashable { }

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
		case text
		case note
		case options
		case view
		case iconName
		case tintColor
		case style
	}
	
	public init(from decoder: any Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)

		self.text = try container.decode(String.self, forKey: .text)
		self.note = try container.decodeIfPresent(String.self, forKey: .note)
		self.options = try container.decode(ItemOptions.self, forKey: .options)
		self.view = try container.decodeIfPresent(View.self, forKey: .view) ?? .list

		let version: Version? = if let key = CodingUserInfoKey.documentVersion {
			decoder.userInfo[key] as? Version
		} else {
			nil
		}

		// MARK: - Versioning

		switch version?.major {
		case 1:
			let style = try container.decode(ItemStyle.self, forKey: .style)
			if case let .section(icon) = style {
				self.iconName = icon?.name
				self.tintColor = options.contains(.marked) ? .yellow : icon?.color
			}
		default:
			self.iconName = try? container.decodeIfPresent(IconName.self, forKey: .iconName)
			self.tintColor = try? container.decodeIfPresent(ItemColor.self, forKey: .tintColor)
		}
	}
	
	public func encode(to encoder: any Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(text, forKey: .text)
		try container.encodeIfPresent(note, forKey: .note)
		try container.encode(options, forKey: .options)
		try container.encode(view, forKey: .view)
		try container.encodeIfPresent(iconName, forKey: .iconName)
		try container.encodeIfPresent(tintColor, forKey: .tintColor)
	}
}

// MARK: - Nested data structs
public extension ItemContent {

	enum View: Int, Codable {
		case list = 0
		case columns = 1
	}

	enum Style: Int, Codable {
		case item
		case section
	}
}

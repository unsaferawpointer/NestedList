//
//  Item.swift
//  CoreModule
//
//  Created by Anton Cherkasov on 14.03.2026.
//

import Foundation
import Hierarchy

public typealias Item = Resolved<ItemContent>

// MARK: - ItemContent interface
public extension Resolved where Content == ItemContent {

	var uuid: UUID {
		get { content.uuid }
		set { content.uuid = newValue }
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
		tintColor: ItemColor? = nil,
		isMirror: Bool = false
	) {
		self.init(
			content: ItemContent(
				uuid: uuid,
				text: text,
				note: note,
				options: options,
				view: view,
				iconName: iconName,
				tintColor: tintColor
			),
			isMirror: isMirror
		)
	}

	init(uuid: UUID = UUID(), properties: ItemProperties, isMirror: Bool = false) {
		self.init(
			content: ItemContent(uuid: uuid, properties: properties),
			isMirror: isMirror
		)
	}

	// MARK: - Public Interface

	func copy(with newId: UUID = .init()) -> Item {
		return Item(
			content: content.copy(with: newId),
			isMirror: isMirror
		)
	}

	// MARK: - Nested data structs

	typealias View = ItemContent.View

	typealias Style = ItemContent.Style
}

// MARK: - Codable
extension Resolved: @retroactive Codable where Content == ItemContent {

	public init(from decoder: any Decoder) throws {
		self.init(content: try ItemContent(from: decoder))
	}

	public func encode(to encoder: any Encoder) throws {
		try content.encode(to: encoder)
	}
}

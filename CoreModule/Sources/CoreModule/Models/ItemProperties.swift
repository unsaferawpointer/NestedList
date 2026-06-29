//
//  ItemProperties.swift
//  CoreModule
//
//  Created by Anton Cherkasov on 29.06.2026.
//

public struct ItemProperties {

	public var text: String

	public var note: String?

	public var options: ItemOptions

	// MARK: - Appearance

	public var iconName: IconName?

	public var tintColor: ItemColor?

	// MARK: - Initialization

	public init(
		text: String,
		note: String? = nil,
		options: ItemOptions = [],
		iconName: IconName? = nil,
		tintColor: ItemColor? = nil
	) {
		self.text = text
		self.note = note
		self.options = options
		self.iconName = iconName
		self.tintColor = tintColor
	}
}

//
//  MenuElement.swift
//  DesignSystem
//
//  Created by Anton Cherkasov on 06.04.2025.
//

public struct MenuElement {

	let id: String

	let title: String

	let icon: String?

	let content: Content

	// MARK: - Initialization

	public init(
		id: String,
		title: String = "",
		icon: String? = nil,
		content: Content
	) {
		self.id = id
		self.title = title
		self.icon = icon
		self.content = content
	}
}

// MARK: - Nested datas structs
public extension MenuElement {

	enum Content {
		case menu(options: MenuOptions, size: ElementSize, items: [MenuElement])
		case item(state: ControlState, attributes: Attributes)
	}

	struct MenuOptions: OptionSet {

		public var rawValue: Int

		public init(rawValue: Int) {
			self.rawValue = rawValue
		}
	}

	struct Attributes : OptionSet {

		public var rawValue: Int

		public init(rawValue: Int) {
			self.rawValue = rawValue
		}

		public static let disabled = Attributes(rawValue: 1 << 0)

		public static let destructive = Attributes(rawValue: 1 << 1)

		public static let hidden = Attributes(rawValue: 1 << 2)

	}

	enum ElementSize: Int {

		case small = 0
		case medium = 1
		case large = 2

		@available(iOS 17.0, *)
		case automatic = -1
	}
}

// MARK: - Templates
public extension MenuElement.MenuOptions {

	static let inline = Self(rawValue: 1 << 0)

	static let destructive = Self (rawValue: 1 << 1)

	static let singleSelection = Self (rawValue: 1 << 5)

	@available(iOS 17, *)
	static let palette = Self (rawValue: 1 << 7)
}

#if canImport(UIKit)

import UIKit

extension MenuElement.ElementSize {

	var value: UIMenu.ElementSize {
		switch self {
		case .small:		.small
		case .medium:		.medium
		case .large:		.large
		case .automatic:
			if #available(iOS 17.0, *) {
				.automatic
			} else {
				.large
			}
		}
	}
}

extension MenuElement.Attributes {

	var value: UIMenuElement.Attributes {
		var result: UIMenu.Attributes = []
		if contains(.destructive) {
			result.insert(.destructive)
		}
		if contains(.disabled) {
			result.insert(.disabled)
		}
		if contains(.hidden) {
			result.insert(.hidden)
		}
		return result
	}
}

extension MenuElement.MenuOptions {

	var value: UIMenu.Options {
		var result: UIMenu.Options = []
		if contains(.inline) {
			result.insert(.displayInline)
		}
		if contains(.destructive) {
			result.insert(.destructive)
		}
		if contains(.singleSelection) {
			result.insert(.singleSelection)
		}
		if #available(iOS 17.0, *) {
			if contains(.palette) {
				result.insert(.displayAsPalette)
			}
		}
		return result
	}
}

#endif

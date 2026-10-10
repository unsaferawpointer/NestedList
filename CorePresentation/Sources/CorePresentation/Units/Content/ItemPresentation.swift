//
//  ItemPresentation.swift
//  CorePresentation
//
//  Created by Anton Cherkasov on 05.10.2026.
//

import Foundation
import DesignSystem

public struct ItemPresentation {

	public let id: UUID

	public let title: Text

	public let subtitle: Text?

	public let compositeIcon: CompositeIconModel?

	public let showsTrailingDisclosure: Bool

	public let isGroup: Bool

	// MARK: - Initialization

	public init(
		id: UUID,
		title: Text,
		subtitle: Text?,
		compositeIcon: CompositeIconModel?,
		showsTrailingDisclosure: Bool,
		isGroup: Bool
	) {
		self.id = id
		self.title = title
		self.subtitle = subtitle
		self.compositeIcon = compositeIcon
		self.showsTrailingDisclosure = showsTrailingDisclosure
		self.isGroup = isGroup
	}
}

// MARK: - Nested data structs
public extension ItemPresentation {

	struct Text {

		public let value: String

		public let style: TextStyle

		public let colorToken: ColorToken

		public let strikethrough: Bool

		// MARK: - Initialization

		public init(
			value: String,
			style: TextStyle,
			colorToken: ColorToken,
			strikethrough: Bool
		) {
			self.value = value
			self.style = style
			self.colorToken = colorToken
			self.strikethrough = strikethrough
		}
	}
}

// MARK: - Equatable
extension ItemPresentation: Equatable { }

// MARK: - Equatable
extension ItemPresentation.Text: Equatable { }

//
//  ToolbarItem.swift
//  DesignSystem
//
//  Created by Anton Cherkasov on 06.04.2025.
//

public struct ToolbarItem {

	public var id: String

	public var title: String

	public var icon: String?

	public var content: Content

	public var isEnabled: Bool

	public var isPrimaryAction: Bool

	// MARK: - Initialization

	public init(
		id: String,
		title: String,
		icon: String? = nil,
		content: Content = .regular,
		isEnabled: Bool = true,
		isPrimaryAction: Bool = false
	) {
		self.id = id
		self.title = title
		self.icon = icon
		self.content = content
		self.isEnabled = isEnabled
		self.isPrimaryAction = isPrimaryAction
	}
}

// MARK: - Nested data structs
public extension ToolbarItem {

	enum Content {
		case regular
		case menu(items: [MenuElement])
		case status(text: String)
		case flexible
	}
}

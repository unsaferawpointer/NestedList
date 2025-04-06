//
//  ToolbarItem.swift
//  DesignSystem
//
//  Created by Anton Cherkasov on 06.04.2025.
//

public struct ToolbarItem {

	public var id: String

	public var title: String

	public var icon: IconName?

	public var content: Content

	public var isEnabled: Bool

	// MARK: - Initialization

	public init(id: String, title: String, icon: IconName? = nil, content: Content = .regular, isEnabled: Bool = true) {
		self.id = id
		self.title = title
		self.icon = icon
		self.content = content
		self.isEnabled = isEnabled
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

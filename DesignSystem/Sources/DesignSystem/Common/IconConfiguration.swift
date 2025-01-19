//
//  IconConfiguration.swift
//  DesignSystem
//
//  Created by Anton Cherkasov on 19.01.2025.
//

public struct IconConfiguration {

	public var iconName: String
	public var color: ColorToken

	// MARK: - Initialization

	public init(iconName: String, color: ColorToken) {
		self.iconName = iconName
		self.color = color
	}
}

// MARK: - Hashable
extension IconConfiguration: Hashable { }

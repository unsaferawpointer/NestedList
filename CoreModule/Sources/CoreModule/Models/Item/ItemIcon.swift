//
//  ItemIcon.swift
//  CoreModule
//
//  Created by Anton Cherkasov on 02.05.2025.
//

import Foundation

public struct ItemIcon {

	public var name: IconName
	public var color: ItemColor

	// MARK: - Initialization

	public init(name: IconName, color: ItemColor) {
		self.name = name
		self.color = color
	}
}

// MARK: - Codable
extension ItemIcon: Codable { }

// MARK: - Hashable
extension ItemIcon: Hashable { }

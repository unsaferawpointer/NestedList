//
//  Feature.swift
//  DesignSystem
//
//  Created by Anton Cherkasov on 01.05.2025.
//

import Foundation

public struct Feature {

	public var id: String

	let icon: String
	let iconColor: ColorToken?
	let title: String
	let description: String

	// MARK: - Initialization

	public init(
		id: String = UUID().uuidString,
		icon: String,
		iconColor: ColorToken? = .accent,
		title: String,
		description: String
	) {
		self.id = id
		self.icon = icon
		self.title = title
		self.description = description
		self.iconColor = iconColor
	}
}

// MARK: - Identifiable
extension Feature: Identifiable { }

// MARK: - Codable
extension Feature: Codable { }

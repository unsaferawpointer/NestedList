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
	public let minVersion: String?
	public let maxVersion: String?

	// MARK: - Initialization

	public init(
		id: String = UUID().uuidString,
		icon: String,
		iconColor: ColorToken? = .accent,
		title: String,
		description: String,
		minVersion: String? = nil,
		maxVersion: String? = nil
	) {
		self.id = id
		self.icon = icon
		self.title = title
		self.description = description
		self.iconColor = iconColor
		self.minVersion = minVersion
		self.maxVersion = maxVersion
	}
}

// MARK: - Identifiable
extension Feature: Identifiable { }

// MARK: - Codable
extension Feature: Codable { }

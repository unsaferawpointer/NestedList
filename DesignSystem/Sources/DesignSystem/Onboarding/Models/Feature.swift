//
//  Feature.swift
//  DesignSystem
//
//  Created by Anton Cherkasov on 01.05.2025.
//

import Foundation

public struct Feature {

	public var id: UUID

	let icon: String
	let title: String
	let description: String

	// MARK: - Initialization

	public init(
		id: UUID = UUID(),
		icon: String,
		title: String,
		description: String
	) {
		self.id = id
		self.icon = icon
		self.title = title
		self.description = description
	}
}

// MARK: - Identifiable
extension Feature: Identifiable { }

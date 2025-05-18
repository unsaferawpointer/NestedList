//
//  Page.swift
//  DesignSystem
//
//  Created by Anton Cherkasov on 30.04.2025.
//

import Foundation

public struct Page {

	public var id: String

	var image: String
	let iconColor: ColorToken?
	var title: String
	var description: String

	var features: [Feature]

	// MARK: - Initialization

	public init(
		id: String,
		image: String,
		iconColor: ColorToken?,
		title: String,
		description: String,
		features: [Feature]
	) {
		self.id = id
		self.image = image
		self.iconColor = iconColor
		self.title = title
		self.description = description
		self.features = features
	}
}

// MARK: - Identifiable
extension Page: Identifiable { }

// MARK: - Codable
extension Page: Codable { }

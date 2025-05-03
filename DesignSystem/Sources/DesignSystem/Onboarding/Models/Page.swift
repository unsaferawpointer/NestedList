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
	var title: String
	var description: String

	var features: [Feature]

	public init(id: String, image: String, title: String, description: String, features: [Feature]) {
		self.id = id
		self.image = image
		self.title = title
		self.description = description
		self.features = features
	}
}

// MARK: - Identifiable
extension Page: Identifiable { }

// MARK: - Codable
extension Page: Codable { }

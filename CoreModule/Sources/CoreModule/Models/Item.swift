//
//  Item.swift
//  CoreModule
//
//  Created by Anton Cherkasov on 16.11.2024.
//

import Foundation
import Hierarchy

public struct Item {

	public var uuid: UUID

	public var isDone: Bool

	public var text: String

	// MARK: - Initialization

	public init(uuid: UUID = UUID(), isDone: Bool = false, text: String) {
		self.uuid = uuid
		self.isDone = isDone
		self.text = text
	}
}

// MARK: - Identifiable
extension Item: Identifiable {

	public var id: UUID {
		uuid
	}
}

// MARK: - Codable
extension Item: Codable { }

// MARK: - NodeValue
extension Item: NodeValue {

	public mutating func generateIdentifier() {
		self.uuid = UUID()
	}
}

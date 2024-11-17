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
}

// MARK: - Identifiable
extension Item: Identifiable {

	public var id: UUID {
		uuid
	}
}

// MARK: - NodeValue
extension Item: NodeValue {

	public mutating func generateIdentifier() {
		self.uuid = UUID()
	}
}

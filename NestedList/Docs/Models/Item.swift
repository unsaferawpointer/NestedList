//
//  Item.swift
//  NestedList
//
//  Created by Anton Cherkasov on 12.11.2024.
//

import Foundation

struct Item {

	var uuid: UUID

	var text: String

	// MARK: - Initialization

	init(uuid: UUID = UUID(), text: String) {
		self.uuid = uuid
		self.text = text
	}
}

// MARK: - Identifiable
extension Item: Identifiable {

	public var id: UUID {
		uuid
	}
}

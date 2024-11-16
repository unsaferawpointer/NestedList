//
//  Item.swift
//  CoreModule
//
//  Created by Anton Cherkasov on 16.11.2024.
//

import Foundation

struct Item {

	var uuid: UUID

	var isDone: Bool

	var text: String
}

// MARK: - Identifiable
extension Item: Identifiable {

	var id: UUID {
		uuid
	}
}

//
//  ItemModel.swift
//  iOS
//
//  Created by Anton Cherkasov on 22.11.2024.
//

import Foundation

struct ItemModel {

	var uuid: UUID

	var title: String

	var isDone: Bool
}

// MARK: - Identifiable
extension ItemModel: Identifiable {

	var id: UUID {
		uuid
	}
}

// MARK: - Hashable
extension ItemModel: Hashable { }

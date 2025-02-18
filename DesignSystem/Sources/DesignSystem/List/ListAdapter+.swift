//
//  ListAdapter+.swift
//  DesignSystem
//
//  Created by Anton Cherkasov on 18.02.2025.
//

import Foundation

extension ListAdapter {

	enum Identifier<ID: Hashable> {
		case item(id: ID)
		case spacer(before: ID)
	}
}

// MARK: - Hashable
extension ListAdapter.Identifier: Hashable { }

// MARK: - Codable
extension ListAdapter.Identifier: Codable where ID: Codable { }

enum ListModel<Model: CellModel> where Model.ID: Codable {
	case model(_ value: Model)
	case spacer(before: Model.ID)
}

// MARK: - Identifiable
extension ListModel: Identifiable {

	var id: ListAdapter<Model>.Identifier<Model.ID> {
		switch self {
		case .model(let value):
			return .item(id: value.id)
		case .spacer(let before):
			return .spacer(before: before)
		}
	}
}

// MARK: - Computed properties
extension ListModel {

	var height: CGFloat? {
		switch self {
		case .model(let value):
			return value.height
		case .spacer:
			return 24.0
		}
	}

	func contentIsEquals(to other: Self) -> Bool {
		switch (self, other) {
		case let (.model(lhs), .model(rhs)):
			return lhs.contentIsEquals(to: rhs)
		case (.spacer, .spacer):
			return true
		default:
			return false
		}
	}

	var isGroup: Bool {
		switch self {
		case .model(let value):
			return value.isGroup
		case .spacer:
			return false
		}
	}
}

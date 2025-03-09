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
	case spacer(before: Model.ID, height: SpacerHeight)
}

// MARK: - Identifiable
extension ListModel: Identifiable {

	var id: ListAdapter<Model>.Identifier<Model.ID> {
		switch self {
		case let .model(value):
			return .item(id: value.id)
		case let .spacer(before, _):
			return .spacer(before: before)
		}
	}
}

enum SpacerHeight: CGFloat {
	case small = 4
	case medium = 8
	case large = 16
}

// MARK: - Computed properties
extension ListModel {

	var height: CGFloat? {
		switch self {
		case let .model(value):
			return value.height
		case let .spacer(_, height):
			return height.rawValue
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

	var isDecoration: Bool {
		switch self {
		case .model:	false
		default:		true
		}
	}
}

//
//  CellModel.swift
//  DesignSystem
//
//  Created by Anton Cherkasov on 16.11.2024.
//

import Hierarchy
import CoreFoundation

public protocol CellModel: Identifiable {

	associatedtype Value

	associatedtype Configuration

	associatedtype Cell: ListCell where Cell.Model == Self

	var configuration: Configuration { get }

	var value: Value { get }

	var action: ((Value) -> Void)? { get }

	var isGroup: Bool { get }

	var height: CGFloat? { get }

	func contentIsEquals(to other: Self) -> Bool
}

// MARK: - Identifiable
extension CellModel where Value: Identifiable {

	var id: Value.ID {
		value.id
	}
}

//
//  CellModel.swift
//  DesignSystem
//
//  Created by Anton Cherkasov on 16.11.2024.
//

import CoreFoundation

#if os(macOS)
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
#elseif os(iOS)

import UIKit

public protocol CellModel: Identifiable, Hashable {

	associatedtype Cell: ListCell where Cell.Model == Self

	var configuration: UIListContentConfiguration { get }

	var selectionConfiguration: UIListContentConfiguration { get }

	func contentIsEquals(to other: Self) -> Bool
}
#endif

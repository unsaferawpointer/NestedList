//
//  ItemOptions.swift
//  CoreModule
//
//  Created by Anton Cherkasov on 01.05.2025.
//

import Foundation

public struct ItemOptions: OptionSet {

	public var rawValue: Int

	public init(rawValue: Int) {
		self.rawValue = rawValue
	}
}

// MARK: - Codable
extension ItemOptions: Codable { }

// MARK: - Hashable
extension ItemOptions: Hashable { }

// MARK: - Temlates
public extension ItemOptions {

	static let strikethrough = ItemOptions(rawValue: 1 << 0)

	@available(*, deprecated, message: "ItemOptions.marked is deprecated and no longer used.")
	static let marked = ItemOptions(rawValue: 1 << 1)
}

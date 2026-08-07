//
//  PasteboardInfo.swift
//  DesignSystem
//
//  Created by Anton Cherkasov on 15.12.2024.
//

import Foundation

public struct PasteboardInfo {

	public var items: [Item] = []

	// MARK: - Initialization

	public init(items: [Item]) {
		self.items = items
	}
}

// MARK: - Public interface
public extension PasteboardInfo {

	func containsInfo(of type: String) -> Bool {
		return items.contains { item in
			item.data[type] != nil
		}
	}
}

// MARK: - Nested data structs
public extension PasteboardInfo {

	struct Item {

		public var data: [String: Data]

		// MARK: - Initialization

		public init(data: [String : Data]) {
			self.data = data
		}
	}
}

public extension PasteboardInfo.Item {

	static let stringType = "public.utf8-plain-text"

	init(string: String) {
		self.data = [Self.stringType: string.data(using: .utf8) ?? Data()]
	}
}

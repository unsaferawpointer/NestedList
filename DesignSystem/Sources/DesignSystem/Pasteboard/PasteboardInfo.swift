//
//  PasteboardInfo.swift
//  DesignSystem
//
//  Created by Anton Cherkasov on 15.12.2024.
//

#if os(macOS)

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

		public init(string: String) {
			self.data = [NSPasteboard.PasteboardType.string.rawValue: string.data(using: .utf8) ?? Data()]
		}
	}
}

#endif

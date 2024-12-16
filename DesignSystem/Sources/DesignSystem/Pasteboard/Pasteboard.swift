//
//  Pasteboard.swift
//  DesignSystem
//
//  Created by Anton Cherkasov on 15.12.2024.
//

import Foundation

#if canImport(AppKit)
import AppKit
#endif

public protocol PasteboardProtocol {

	func contains(_ types: Set<String>) -> Bool
	func info(for types: Set<String>) -> PasteboardInfo?
	func setInfo(_ info: PasteboardInfo, clearContents: Bool)
}

final class Pasteboard {

	let pasteboard: NSPasteboard

	// MARK: - Initialization

	init(pasteboard: NSPasteboard = .general) {
		self.pasteboard = pasteboard
	}
}

// MARK: - PasteboardProtocol
extension Pasteboard: PasteboardProtocol {

	func contains(_ types: Set<String>) -> Bool {
		return types.contains { type in
			pasteboard.data(forType: .init(type)) != nil
		}
	}

	func info(for types: Set<String>) -> PasteboardInfo? {
		let items = pasteboard.pasteboardItems?.map { item in
			let tuples = types.compactMap { identifier -> (String, Data)? in
				guard let data = item.data(forType: .init(identifier)) else {
					return nil
				}
				return (identifier, data)
			}
			let data = Dictionary(uniqueKeysWithValues: tuples)
			return PasteboardInfo.Item(data: data)
		}

		guard let items else {
			return nil
		}

		return PasteboardInfo(items: items)
	}

	func setInfo(_ info: PasteboardInfo, clearContents: Bool) {

		if clearContents {
			pasteboard.clearContents()
		}

		let items = info.items.map {
			let item = NSPasteboardItem()
			for (key, data) in $0.data {
				if key == NSPasteboard.PasteboardType.string.rawValue {
					item.setString(String(data: data, encoding: .utf8) ?? "", forType: .string)
					continue
				}
				item.setData(data, forType: .init(key))
			}
			return item
		}

		print("info = \(info)")

		pasteboard.writeObjects(items)
	}
}

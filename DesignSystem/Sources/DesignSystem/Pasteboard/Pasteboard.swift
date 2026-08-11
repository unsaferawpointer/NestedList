//
//  Pasteboard.swift
//  DesignSystem
//
//  Created by Anton Cherkasov on 15.12.2024.
//

import Foundation

public protocol PasteboardProtocol {

	func contains(_ types: Set<String>) -> Bool
	func setInfo(_ info: PasteboardInfo, clearContents: Bool)
	func getInfo() -> PasteboardInfo?
}


#if os(macOS)
import AppKit

public final class Pasteboard {

	let pasteboard: NSPasteboard

	// MARK: - Initialization

	public init(pasteboard: NSPasteboard = .general) {
		self.pasteboard = pasteboard
	}
}

// MARK: - PasteboardProtocol
extension Pasteboard: PasteboardProtocol {

	public func getInfo() -> PasteboardInfo? {
		let types = pasteboard.types?.map(\.rawValue) ?? []
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

	public func contains(_ types: Set<String>) -> Bool {
		return types.contains { type in
			pasteboard.data(forType: .init(type)) != nil
		}
	}

	public func setInfo(_ info: PasteboardInfo, clearContents: Bool) {

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
		pasteboard.writeObjects(items)
	}
}
#elseif os(iOS)
import UIKit

public final class Pasteboard {

	let pasteboard: UIPasteboard

	// MARK: - Initialization

	public init(pasteboard: UIPasteboard = .general) {
		self.pasteboard = pasteboard
	}
}

// MARK: - PasteboardProtocol
extension Pasteboard: PasteboardProtocol {

	public func getInfo() -> PasteboardInfo? {
		let items = pasteboard.items.map { item in
			let tuples = item.compactMap { key, value -> (String, Data)? in
				if let data = value as? Data {
					return (key, data)
				}

				if let string = value as? String, let data = string.data(using: .utf8) {
					return (key, data)
				}

				return nil
			}
			let data = Dictionary(uniqueKeysWithValues: tuples)
			print("___TEST key \(data)")
			return PasteboardInfo.Item(data: data)
		}

		guard !items.isEmpty else {
			return nil
		}

		return PasteboardInfo(items: items)
	}

	public func contains(_ types: Set<String>) -> Bool {
		return pasteboard.items.contains { item in
			!types.isDisjoint(with: item.keys)
		}
	}

	public func setInfo(_ info: PasteboardInfo, clearContents: Bool) {
		let items = info.items.map { item in
			let tuples = item.data.map { key, data -> (String, Any) in
				guard key == PasteboardInfo.Item.stringType else {
					return (key, data)
				}

				if let string = String(data: data, encoding: .utf8) {
					return (key, string)
				}

				return (key, data)
			}
			return Dictionary(uniqueKeysWithValues: tuples)
		}

		if clearContents {
			pasteboard.items = items
			return
		}

		pasteboard.items.append(contentsOf: items)
	}
}
#endif

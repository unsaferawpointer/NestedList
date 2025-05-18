//
//  ItemStyle.swift
//  CoreModule
//
//  Created by Anton Cherkasov on 02.05.2025.
//

import Foundation

public enum ItemStyle {
	case item
	case section(icon: ItemIcon?)
}

// MARK: - Hashable
extension ItemStyle: Hashable { }

// MARK: - Codable
extension ItemStyle: Codable {

	public init(from decoder: any Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		var allKeys = ArraySlice(container.allKeys)
		guard let onlyKey = allKeys.popFirst(), allKeys.isEmpty else {
			throw DecodingError.typeMismatch(
				ItemStyle.self,
				DecodingError.Context(
					codingPath: container.codingPath,
					debugDescription: "Invalid number of keys found, expected one.",
					underlyingError: nil
				)
			)
		}
		switch onlyKey {
		case .item:
			self = .item
		case .section:
			let nestedContainer = try container.nestedContainer(
				keyedBy: ItemStyle.SectionCodingKeys.self,
				forKey: .section
			)
			let icon = try? nestedContainer.decodeIfPresent(
				ItemIcon.self,
				forKey: ItemStyle.SectionCodingKeys.icon
			)
			self = .section(icon: icon)
		}
	}
}

// MARK: - Public Interface
public extension ItemStyle {

	var isSection: Bool {
		guard case .section = self else {
			return false
		}
		return true
	}

	func toggle(isSection: Bool) -> Self {
		switch self {
		case .item:
			return .section(icon: nil)
		case .section:
			return .item
		}
	}

	var color: ItemColor? {
		get {
			switch self {
			case .item:
				return nil
			case .section(let icon):
				return icon?.color
			}
		}
	}
}

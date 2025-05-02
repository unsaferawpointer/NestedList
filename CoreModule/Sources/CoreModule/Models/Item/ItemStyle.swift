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
extension ItemStyle: Codable { }

// MARK: - Public Interface
public extension ItemStyle {

	var isSection: Bool {
		guard case .section = self else {
			return false
		}
		return true
	}
}

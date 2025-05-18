//
//  ItemColor.swift
//  CoreModule
//
//  Created by Anton Cherkasov on 13.05.2025.
//

import Foundation

public enum ItemColor: Int {

	case accent = 1

	case primary = 2
	case secondary = 3
	case tertiary = 4
	case quaternary = 5

	// MARK: - Accent

	case red = 10
	case orange = 11
	case yellow = 12
	case green = 13
	case mint = 14
	case teal = 15
	case cyan = 16
	case blue = 17
	case indigo = 18
	case purple = 19
	case pink = 20
	case brown = 21
}

// MARK: - Hashable
extension ItemColor: Hashable { }

// MARK: - Codable
extension ItemColor: Codable { }

// MARK: - CaseIterable
extension ItemColor: CaseIterable { }

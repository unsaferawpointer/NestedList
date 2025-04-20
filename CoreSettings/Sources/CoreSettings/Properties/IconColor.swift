//
//  IconColor.swift
//  CoreSettings
//
//  Created by Anton Cherkasov on 20.04.2025.
//

import Foundation

public enum IconColor: Int {
	case neutral = 0
	case accent
}

// MARK: - Hashable
extension IconColor: Hashable { }

// MARK: - SettingsProperty
extension IconColor: SettingsProperty {

	static var key: String {
		"section_icon_color"
	}
}

import DesignSystem

public extension IconColor {

	var color: ColorToken {
		switch self {
		case .neutral:		.gray
		case .accent:		.accent
		}
	}
}

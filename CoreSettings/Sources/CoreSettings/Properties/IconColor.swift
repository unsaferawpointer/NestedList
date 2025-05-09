//
//  IconColor.swift
//  CoreSettings
//
//  Created by Anton Cherkasov on 20.04.2025.
//

import Foundation
import DesignSystem

public enum IconColor: Int {
	case neutral = 0
	case accent
	case primary
	case multicolor
}

// MARK: - Hashable
extension IconColor: Hashable { }

// MARK: - SettingsProperty
extension IconColor: SettingsProperty {

	static var key: String {
		"section_icon_color"
	}
}

public extension IconColor {

	var color: ColorToken? {
		switch self {
		case .neutral:		.tertiary
		case .accent:		.accent
		case .primary:		.primary
		case .multicolor:	nil
		}
	}
}

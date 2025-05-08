//
//  ColorToken.swift
//  DesignSystem
//
//  Created by Anton Cherkasov on 27.12.2024.
//

public enum ColorToken: Int {

	// MARK: - Basic
	case clear = 0
	case accent = 1
	case primary = 2
	case secondary = 3
	case tertiary = 4
	case quaternary = 5

	case disabledText = 6

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

	case gray = 22
}

// MARK: - Codable
extension ColorToken: Codable { }

// MARK: - Hashable
extension ColorToken: Hashable { }

#if os(macOS)
import AppKit
import SwiftUI

public extension ColorToken {

	var color: Color {
		Color(nsColor: value)
	}

	var value: NSColor {
		switch self {
		case .clear:
			return .clear
		case .accent:
			return .controlAccentColor
		case .primary:
			return .labelColor
		case .secondary:
			return .secondaryLabelColor
		case .tertiary:
			return .tertiaryLabelColor
		case .quaternary:
			return .quaternaryLabelColor
		case .yellow:
			return .systemYellow
		case .red:
			return .systemRed
		case .orange:
			return .systemOrange
		case .green:
			return .systemGreen
		case .mint:
			return .systemMint
		case .teal:
			return .systemTeal
		case .cyan:
			return .systemCyan
		case .blue:
			return .systemBlue
		case .indigo:
			return .systemIndigo
		case .purple:
			return .systemPurple
		case .pink:
			return .systemPink
		case .brown:
			return .systemBrown
		case .disabledText:
			return NSColor(name: nil) { appearance in
				appearance.name == .darkAqua
					? NSColor(white: 0.8, alpha: 0.85)
					: NSColor(white: 0.2, alpha: 0.85)
			}
		case .gray:
			return NSColor(name: nil) { appearance in
				appearance.name == .darkAqua
				? NSColor(white: 0.75, alpha: 1.0)
				: NSColor(white: 0.75, alpha: 1.0)
			}
		}
	}
}
#endif

#if os(iOS)
import UIKit
import SwiftUI

public extension ColorToken {

	var color: Color {
		Color(uiColor: value)
	}

	var value: UIColor {
		switch self {
		case .clear:
			return .clear
		case .accent:
			return .tintColor
		case .primary:
			return .label
		case .secondary:
			return .secondaryLabel
		case .tertiary:
			return .tertiaryLabel
		case .quaternary:
			return .quaternaryLabel
		case .yellow:
			return .systemYellow
		case .red:
			return .systemRed
		case .orange:
			return .systemOrange
		case .green:
			return .systemGreen
		case .mint:
			return .systemMint
		case .teal:
			return .systemTeal
		case .cyan:
			return .systemCyan
		case .blue:
			return .systemBlue
		case .indigo:
			return .systemIndigo
		case .purple:
			return .systemPurple
		case .pink:
			return .systemPink
		case .brown:
			return .brown
		case .disabledText:
			return UIColor { traits in
				traits.userInterfaceStyle == .dark
					? UIColor(white: 0.8, alpha: 0.75)
					: UIColor(white: 0.2, alpha: 0.75)
			}
		case .gray:
			return UIColor { traits in
				traits.userInterfaceStyle == .dark
					? UIColor(white: 0.75, alpha: 1.0)
					: UIColor(white: 0.75, alpha: 1.0)
			}
		}
	}
}
#endif

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
	case coral = 23
	case orange = 11
	case yellow = 12
	case yellowGreen = 24
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

// MARK: - CaseIterable
extension ColorToken: CaseIterable { }

// MARK: - Computed Properties
public extension ColorToken {

	var displayName: String {
		switch self {
		case .clear:
			String(localized: "transparent-display-name", table: "ColorLocalizable", bundle: .module)
		case .accent:
			String(localized: "accent-display-name", table: "ColorLocalizable", bundle: .module)
		case .primary:
			String(localized: "primary-display-name", table: "ColorLocalizable", bundle: .module)
		case .secondary:
			String(localized: "secondary-display-name", table: "ColorLocalizable", bundle: .module)
		case .tertiary:
			String(localized: "tertiary-display-name", table: "ColorLocalizable", bundle: .module)
		case .quaternary:
			String(localized: "quaternary-display-name", table: "ColorLocalizable", bundle: .module)
		case .disabledText:
			String(localized: "disabled-text-display-name", table: "ColorLocalizable", bundle: .module)
		case .red:
			String(localized: "red-display-name", table: "ColorLocalizable", bundle: .module)
		case .coral:
			String(localized: "coral-display-name", table: "ColorLocalizable", bundle: .module)
		case .orange:
			String(localized: "orange-display-name", table: "ColorLocalizable", bundle: .module)
		case .yellow:
			String(localized: "yellow-display-name", table: "ColorLocalizable", bundle: .module)
		case .yellowGreen:
			String(localized: "yellow-green-display-name", table: "ColorLocalizable", bundle: .module)
		case .green:
			String(localized: "green-display-name", table: "ColorLocalizable", bundle: .module)
		case .mint:
			String(localized: "mint-display-name", table: "ColorLocalizable", bundle: .module)
		case .teal:
			String(localized: "teal-display-name", table: "ColorLocalizable", bundle: .module)
		case .cyan:
			String(localized: "cyan-display-name", table: "ColorLocalizable", bundle: .module)
		case .blue:
			String(localized: "blue-display-name", table: "ColorLocalizable", bundle: .module)
		case .indigo:
			String(localized: "indigo-display-name", table: "ColorLocalizable", bundle: .module)
		case .purple:
			String(localized: "purple-display-name", table: "ColorLocalizable", bundle: .module)
		case .pink:
			String(localized: "pink-display-name", table: "ColorLocalizable", bundle: .module)
		case .brown:
			String(localized: "brown-display-name", table: "ColorLocalizable", bundle: .module)
		case .gray:
			String(localized: "gray-display-name", table: "ColorLocalizable", bundle: .module)
		}
	}
}

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
		case .coral:
			return NSColor(name: nil) { appearance in
				appearance.name == .darkAqua
				? NSColor(red: 1.0, green: 118.0 / 255.0, blue: 72.0 / 255.0, alpha: 1.0)
				: NSColor(red: 1.0, green: 105.0 / 255.0, blue: 64.0 / 255.0, alpha: 1.0)
			}
		case .orange:
			return .systemOrange
		case .green:
			return .systemGreen
		case .yellowGreen:
			return NSColor(name: nil) { appearance in
				appearance.name == .darkAqua
				? NSColor(red: 180.0 / 255.0, green: 224.0 / 255.0, blue: 64.0 / 255.0, alpha: 1.0)
				: NSColor(red: 164.0 / 255.0, green: 211.0 / 255.0, blue: 48.0 / 255.0, alpha: 1.0)
			}
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
					: NSColor(white: 0.3, alpha: 0.85)
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
		case .coral:
			return UIColor { traits in
				traits.userInterfaceStyle == .dark
				? UIColor(red: 1.0, green: 118.0 / 255.0, blue: 72.0 / 255.0, alpha: 1.0)
				: UIColor(red: 1.0, green: 105.0 / 255.0, blue: 64.0 / 255.0, alpha: 1.0)
			}
		case .orange:
			return .systemOrange
		case .green:
			return .systemGreen
		case .yellowGreen:
			return UIColor { traits in
				traits.userInterfaceStyle == .dark
				? UIColor(red: 180.0 / 255.0, green: 224.0 / 255.0, blue: 64.0 / 255.0, alpha: 1.0)
				: UIColor(red: 164.0 / 255.0, green: 211.0 / 255.0, blue: 48.0 / 255.0, alpha: 1.0)
			}
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
					: UIColor(white: 0.3, alpha: 0.75)
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

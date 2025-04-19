//
//  ColorToken.swift
//  DesignSystem
//
//  Created by Anton Cherkasov on 27.12.2024.
//

public enum ColorToken {

	// MARK: - Basic
	case clear
	case accent
	case primary
	case secondary
	case tertiary
	case quaternary

	case disabledText

	// MARK: - Accent

	case red
	case orange
	case yellow
	case green
	case mint
	case teal
	case cyan
	case blue
	case indigo
	case purple
	case pink

	case gray
}

// MARK: - Hashable
extension ColorToken: Hashable { }

#if os(macOS)
import AppKit

public extension ColorToken {

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
		case .disabledText:
			return NSColor(name: nil) { appearance in
				appearance.name == .darkAqua
					? NSColor(white: 0.8, alpha: 0.85)
					: NSColor(white: 0.2, alpha: 0.85)
			}
		case .gray:
			return NSColor(name: nil) { appearance in
				appearance.name == .darkAqua
				? NSColor(white: 0.7, alpha: 1.0)
				: NSColor(white: 0.8, alpha: 1.0)
			}
		}
	}
}
#endif

#if os(iOS)
import UIKit

public extension ColorToken {

	var color: UIColor {
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
		case .disabledText:
			return UIColor { traits in
				traits.userInterfaceStyle == .dark
					? UIColor(white: 0.8, alpha: 0.75)
					: UIColor(white: 0.2, alpha: 0.75)
			}
		case .gray:
			return UIColor { traits in
				traits.userInterfaceStyle == .dark
					? UIColor(white: 0.7, alpha: 1.0)
					: UIColor(white: 0.8, alpha: 1.0)
			}
		}
	}
}
#endif

//
//  ColorToken.swift
//  DesignSystem
//
//  Created by Anton Cherkasov on 27.12.2024.
//

public enum ColorToken {

	// MARK: - Basic
	case accent
	case primary
	case secondary
	case tertiary
	case quaternary

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
}

// MARK: - Hashable
extension ColorToken: Hashable { }

#if os(macOS)
import AppKit

public extension ColorToken {

	var color: NSColor {
		switch self {
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
		}
	}
}
#endif

#if os(iOS)
import UIKit

public extension ColorToken {

	var color: UIColor {
		switch self {
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
		}
	}
}
#endif

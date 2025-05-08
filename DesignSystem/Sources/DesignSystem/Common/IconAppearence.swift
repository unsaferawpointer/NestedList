//
//  IconAppearence.swift
//  DesignSystem
//
//  Created by Anton Cherkasov on 20.03.2025.
//

public enum IconAppearence {
	case monochrome(token: ColorToken)
	case hierarchical(token: ColorToken)
	case palette(tokens: [ColorToken])
	case multicolor
}

// MARK: - Hashable
extension IconAppearence: Hashable { }

#if os(macOS)
import AppKit

public extension IconAppearence {

	var configuration: NSImage.SymbolConfiguration {
		switch self {
		case .monochrome:
			.preferringMonochrome()
		case let .hierarchical(token):
			.init(hierarchicalColor: token.value)
		case let .palette(tokens):
			.init(paletteColors: tokens.map(\.value))
		case .multicolor:
			.preferringMulticolor()
		}
	}

	var tint: NSColor? {
		switch self {
		case let .monochrome(token):
			token.value
		default:
			.controlAccentColor
		}
	}

}
#endif

#if os(iOS)
import UIKit

public extension IconAppearence {

	var configuration: UIImage.SymbolConfiguration {
		switch self {
		case .monochrome:
			.preferringMonochrome()
		case let .hierarchical(token):
			.init(hierarchicalColor: token.value)
		case let .palette(tokens):
			.init(paletteColors: tokens.map(\.value))
		case .multicolor:
			.preferringMulticolor()
		}
	}

	var tint: UIColor? {
		switch self {
		case let .monochrome(token):
			token.value
		default:
			nil
		}
	}
}
#endif

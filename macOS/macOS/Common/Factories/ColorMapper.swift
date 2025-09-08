//
//  ColorMapper.swift
//  Nested List
//
//  Created by Anton Cherkasov on 13.05.2025.
//

import CoreModule
import DesignSystem

final class ColorMapper {

	static func map(color: ItemColor?) -> ColorToken {
		guard let color else {
			return .tertiary
		}
		return switch color {
		case .accent: .accent

		case .primary: .primary
		case .secondary: .secondary
		case .tertiary: .tertiary
		case .quaternary: .quaternary

		// MARK: - Accent

		case .red: .red
		case .orange: .orange
		case .yellow: .yellow
		case .green: .green
		case .mint: .mint
		case .teal: .teal
		case .cyan: .cyan
		case .blue: .blue
		case .indigo: .indigo
		case .purple: .purple
		case .pink: .pink
		case .brown: .brown
		}
	}

	static func map(token: ColorToken?) -> ItemColor? {
		guard let token else {
			return .tertiary
		}
		return switch token {
		case .accent: .accent

		case .primary: .primary
		case .secondary: .secondary
		case .tertiary: .tertiary
		case .quaternary: .quaternary

		// MARK: - Accent

		case .red: .red
		case .orange: .orange
		case .yellow: .yellow
		case .green: .green
		case .mint: .mint
		case .teal: .teal
		case .cyan: .cyan
		case .blue: .blue
		case .indigo: .indigo
		case .purple: .purple
		case .pink: .pink
		case .brown: .brown

		default:	nil
		}
	}
}

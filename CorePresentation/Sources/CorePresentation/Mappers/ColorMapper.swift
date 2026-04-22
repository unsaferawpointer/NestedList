//
//  ColorMapper.swift
//  CorePresentation
//
//  Created by Anton Cherkasov on 29.09.2025.
//

import CoreModule
import DesignSystem

public final class ColorMapper {

	public static func map(color: ItemColor?) -> ColorToken {
		guard let color else {
			return .tertiary
		}
			return switch color {
			case .unknown: .tertiary
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

	public static func map(token: ColorToken?) -> ItemColor? {
		guard let token else {
			return nil
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

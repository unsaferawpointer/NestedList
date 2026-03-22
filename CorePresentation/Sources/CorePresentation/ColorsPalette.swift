//
//  ColorsPalette.swift
//  CorePresentation
//
//  Created by Anton Cherkasov on 22.03.2026.
//

import Foundation
import CoreModule

@MainActor
public struct ColorsPalette {

	public static let colors: [ItemColor] = ItemColor.allCases.sorted { lhs, rhs in
		lhs.rawValue < rhs.rawValue
	}
}

// MARK: - Public Interface
public extension ColorsPalette {

	static func chunked() -> [[ItemColor]] {
		return colors.chunked(into: 4)
	}

	static func grouped() -> [[ItemColor]] {
		[
			[.accent],
			[.primary, .secondary, .tertiary, .quaternary],
			[
				.red, .orange, .yellow, .green,
				.mint, .teal, .cyan, .blue,
				.indigo, .purple, .pink, .brown
			]
		]
	}
}

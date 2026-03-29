//
//  IconsPalette.swift
//  CorePresentation
//
//  Created by Anton Cherkasov on 21.03.2026.
//

import Foundation
import CoreModule

@MainActor
public struct IconsPalette {

	public static let icons: [IconName] = IconName.allCases.sorted { lhs, rhs in
		lhs.order < rhs.order
	}
}

// MARK: - Public Interface
public extension IconsPalette {

	static func chunked() -> [[IconName]] {
		return icons.chunked(into: 4)
	}
}

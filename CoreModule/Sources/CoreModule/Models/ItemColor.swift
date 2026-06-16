//
//  ItemColor.swift
//  CoreModule
//
//  Created by Anton Cherkasov on 13.05.2025.
//

import Foundation

public enum ItemColor {

	case accent

	case primary
	case secondary
	case tertiary
	case quaternary

	// MARK: - Accent

	case red
	case coral
	case orange
	case yellow
	case yellowGreen
	case green
	case mint
	case teal
	case cyan
	case blue
	case indigo
	case violet
	case purple
	case pink
	case brown
	case unknown(Int)
}

// MARK: - RawRepresentable
extension ItemColor: RawRepresentable {

	public init?(rawValue: Int) {
		switch rawValue {
		case 1: 		self = .accent
		case 2: 		self = .primary
		case 3: 		self = .secondary
		case 4: 		self = .tertiary
		case 5: 		self = .quaternary
		case 10: 		self = .red
		case 23: 		self = .coral
		case 11: 		self = .orange
		case 12: 		self = .yellow
		case 24: 		self = .yellowGreen
		case 13: 		self = .green
		case 14: 		self = .mint
		case 15: 		self = .teal
		case 16: 		self = .cyan
		case 17: 		self = .blue
		case 18: 		self = .indigo
		case 25: 		self = .violet
		case 19: 		self = .purple
		case 20: 		self = .pink
		case 21: 		self = .brown
		default: 		self = .unknown(rawValue)
		}
	}

	public var rawValue: Int {
		switch self {
		case .accent: 		1
		case .primary: 		2
		case .secondary: 	3
		case .tertiary: 	4
		case .quaternary: 	5
		case .red: 			10
		case .coral: 		23
		case .orange: 		11
		case .yellow: 		12
		case .yellowGreen: 	24
		case .green: 		13
		case .mint: 		14
		case .teal: 		15
		case .cyan: 		16
		case .blue: 		17
		case .indigo: 		18
		case .violet: 		25
		case .purple: 		19
		case .pink: 		20
		case .brown: 		21
		case let .unknown(rawValue): rawValue
		}
	}
}

// MARK: - Hashable
extension ItemColor: Hashable { }

// MARK: - Codable
extension ItemColor: Codable { }

// MARK: - CaseIterable
extension ItemColor: CaseIterable {

	public static var allCases: [ItemColor] {
		[
			.accent,
			.primary,
			.secondary,
			.tertiary,
			.quaternary,
			.red,
			.coral,
			.orange,
			.yellow,
			.yellowGreen,
			.green,
			.mint,
			.teal,
			.cyan,
			.blue,
			.indigo,
			.violet,
			.purple,
			.pink,
			.brown
		]
	}
}

//
//	IconName.swift
//	CoreModule
//
//	Created by Anton Cherkasov on 13.05.2025.
//

import Foundation

public enum IconName {

	case document
	case documents
	case folder
	case package
	case archivebox
	case stack
	case book
	case squareGrid2x2
	case listStar

	// MARK: - v2.0.0

	case person
	case cloud
	case sun
	case moonStars
	case sparkles
	case flame

	case creditcard
	case gift
	case trash
	case receipt
	case terminal
	case calendar
	case clock
	case xmarkApp
	case checkmarkApp
	case xmarkDiamond
	case checkmarkDiamond
	case pc
	case location
	case bookmark
	case tag
	case squareOnSquare
	case insetDiamond
	case bell
	case conversation
	case envelope
	case gearshape
	case suitcase
	case key
	case airplane
	case carRear
	case film
	case photo
	case photoOnRectangle
	case insetCircle
	case insetSquare
	case insetTriangle
	case personGroup
	case leaf
	case house

	// MARK: - v1.0.0

	case star
	case heart
	case bolt
	case unknown(Int)
}

// MARK: - RawRepresentable
extension IconName: RawRepresentable {

	public init?(rawValue: Int) {
		switch rawValue {
		case 10: self = .document
		case 11: self = .documents
		case 12: self = .folder
		case 13: self = .package
		case 14: self = .archivebox
		case 15: self = .stack
		case 16: self = .book
		case 17: self = .squareGrid2x2
		case 18: self = .listStar
		case 19: self = .person
		case 20: self = .cloud
		case 21: self = .sun
		case 22: self = .sparkles
		case 23: self = .flame
		case 24: self = .creditcard
		case 25: self = .gift
		case 27: self = .trash
		case 29: self = .receipt
		case 31: self = .terminal
		case 32: self = .calendar
		case 35: self = .squareOnSquare
		case 37: self = .insetDiamond
		case 38: self = .bell
		case 40: self = .conversation
		case 42: self = .envelope
		case 43: self = .gearshape
		case 47: self = .suitcase
		case 50: self = .key
		case 52: self = .airplane
		case 53: self = .carRear
		case 54: self = .film
		case 55: self = .photo
		case 56: self = .photoOnRectangle
		case 61: self = .insetCircle
		case 62: self = .insetSquare
		case 63: self = .personGroup
		case 64: self = .leaf
		case 65: self = .house
		case 66: self = .insetTriangle
		case 67: self = .moonStars
		case 68: self = .clock
		case 70: self = .pc
		case 71: self = .location
		case 72: self = .bookmark
		case 73: self = .tag
		case 78: self = .xmarkApp
		case 81: self = .checkmarkApp
		case 82: self = .xmarkDiamond
		case 83: self = .checkmarkDiamond
		case 100: self = .star
		case 101: self = .heart
		case 102: self = .bolt
		default: self = .unknown(rawValue)
		}
	}

	public var rawValue: Int {
		switch self {
		case .document:					10
		case .documents:				11
		case .folder:					12
		case .package:					13
		case .archivebox:				14
		case .stack:					15
		case .book:						16
		case .squareGrid2x2:			17
		case .listStar:					18
		case .person:					19
		case .cloud:					20
		case .sun:						21
		case .sparkles:					22
		case .flame:					23
		case .creditcard:				24
		case .gift:						25
		case .trash:					27
		case .receipt:					29
		case .terminal:					31
		case .calendar:					32
		case .squareOnSquare:			35
		case .insetDiamond:				37
		case .bell:						38
		case .conversation:				40
		case .envelope:					42
		case .gearshape:				43
		case .suitcase:					47
		case .key:						50
		case .airplane:					52
		case .carRear:					53
		case .film:						54
		case .photo:					55
		case .photoOnRectangle:			56
		case .insetCircle:				61
		case .insetSquare:				62
		case .personGroup:				63
		case .leaf:						64
		case .house:					65
		case .insetTriangle:			66
		case .moonStars:				67
		case .clock:					68
		case .pc:						70
		case .location:					71
		case .bookmark:					72
		case .tag:						73
		case .xmarkApp:					78
		case .checkmarkApp:				81
		case .xmarkDiamond:				82
		case .checkmarkDiamond:			83
		case .star:						100
		case .heart:					101
		case .bolt:						102
		case let .unknown(rawValue):	rawValue
		}
	}
}

// MARK: - Codable
extension IconName: Codable { }

// MARK: - Hashable
extension IconName: Hashable { }

// MARK: - CaseIterable
extension IconName: CaseIterable {

	public static var allCases: [IconName] {
		[
			.document,
			.documents,
			.folder,
			.package,
			.archivebox,
			.stack,
			.book,
			.squareGrid2x2,
			.listStar,
			.person,
			.cloud,
			.sun,
			.moonStars,
			.sparkles,
			.flame,
			.creditcard,
			.gift,
			.trash,
			.receipt,
			.terminal,
			.calendar,
			.clock,
			.xmarkApp,
			.checkmarkApp,
			.xmarkDiamond,
			.checkmarkDiamond,
			.pc,
			.location,
			.bookmark,
			.tag,
			.squareOnSquare,
			.insetDiamond,
			.bell,
			.conversation,
			.envelope,
			.gearshape,
			.suitcase,
			.key,
			.airplane,
			.carRear,
			.film,
			.photo,
			.photoOnRectangle,
			.insetCircle,
			.insetSquare,
			.insetTriangle,
			.personGroup,
			.leaf,
			.house,
			.star,
			.heart,
			.bolt
		]
	}
}


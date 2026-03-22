//
//	IconName.swift
//	CoreModule
//
//	Created by Anton Cherkasov on 13.05.2025.
//

import Foundation

public enum IconName: Int {

	case document = 10
	case documents = 11
	case folder = 12
	case package = 13
	case archivebox = 14
	case stack = 15
	case book = 16
	case squareGrid2x2 = 17
	case listStar = 18

	// MARK: - v2.0.0

	case person = 19
	case cloud = 20
	case sun = 21
	case moonStars = 67
	case sparkles = 22
	case flame = 23

	case creditcard = 24
	case gift = 25
	case trash = 27
	case receipt = 29
	case terminal = 31
	case calendar = 32
	case clock = 68
	case xmarkApp = 78
	case checkmarkApp = 81
	case xmarkDiamond = 82
	case checkmarkDiamond = 83
	case pc = 70
	case location = 71
	case bookmark = 72
	case tag = 73
	case squareOnSquare = 35
	case insetDiamond = 37
	case bell = 38
	case conversation = 40
	case envelope = 42
	case gearshape = 43
	case suitcase = 47
	case key = 50
	case airplane = 52
	case carRear = 53
	case film = 54
	case photo = 55
	case photoOnRectangle = 56
	case insetCircle = 61
	case insetSquare = 62
	case insetTriangle = 66
	case personCropSquareOnSquareAngled = 63
	case leaf = 64
	case house = 65

	// MARK: - v1.0.0

	case star = 100
	case heart = 101
	case bolt = 102
}

// MARK: - Codable
extension IconName: Codable { }

// MARK: - Hashable
extension IconName: Hashable { }

// MARK: - CaseIterable
extension IconName: CaseIterable { }

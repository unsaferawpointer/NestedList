//
//	IconName + Extension.swift
//	CorePresentation
//
//	Created by Anton Cherkasov on 21.03.2026.
//

import CoreModule

extension IconName {

	var order: Int {
		switch self {
		case .insetDiamond: 0
		case .insetCircle: 1
		case .insetSquare: 2
		case .insetTriangle: 3
		case .xmarkApp: 4
		case .checkmarkApp: 5
		case .xmarkDiamond: 6
		case .checkmarkDiamond: 7
		case .listStar: 8
		case .film: 9
		case .photo: 10
		case .photoOnRectangle: 11
		case .conversation: 12
		case .envelope: 13
		case .person: 14
		case .personGroup: 15
		case .package: 16
		case .archivebox: 17
		case .stack: 18
		case .folder: 19
		case .squareOnSquare: 20
		case .squareGrid2x2: 21
		case .document: 22
		case .documents: 23
		case .book: 24
		case .sun: 25
		case .moonStars: 26
		case .cloud: 27
		case .leaf: 28
		case .flame: 29
		case .house: 30
		case .bolt: 31
		case .sparkles: 32
		case .suitcase: 33
		case .carRear: 34
		case .airplane: 35
		case .location: 36
		case .star: 37
		case .heart: 38
		case .bookmark: 39
		case .tag: 40
		case .creditcard: 41
		case .receipt: 42
		case .gift: 43
		case .calendar: 44
		case .clock: 45
		case .bell: 46
		case .terminal: 47
		case .gearshape: 48
		case .pc: 49
		case .trash: 50
		case .key: 51
		case .unknown: -1
		}
	}
}
